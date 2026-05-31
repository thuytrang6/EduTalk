import hmac
import hashlib
import uuid
import requests
import logging
import json
import random
import string
import re
import os
from datetime import datetime, timedelta, timezone
from flask import Blueprint, request, jsonify
from firebase_admin import firestore

payment_bp = Blueprint('payment', __name__)
logging.basicConfig(level=logging.INFO)

# ── CONFIGURATION ──────────────────────────────────────────────────────────────
MOMO_CONFIG = {
    "partnerCode": os.environ.get("MOMO_PARTNER_CODE", "MOMOBKUN20180529"),
    "accessKey":   os.environ.get("MOMO_ACCESS_KEY", "klm05TvNBzhg7h7j"),
    "secretKey":   os.environ.get("MOMO_SECRET_KEY", "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa"),
    "endpoint":    os.environ.get("MOMO_ENDPOINT", "https://test-payment.momo.vn/v2/gateway/api/create"),
    "redirectUrl": os.environ.get("MOMO_REDIRECT_URL", "edutalk://payment-result"),
    "ipnUrl":      os.environ.get("MOMO_IPN_URL", "https://edutalk-7ndf.onrender.com/payment/payment-callback"),
    "requestType": "captureWallet"
}

SEPAY_CONFIG = {
    "apiKey": os.environ.get("SEPAY_API_KEY", "EduTalk2025SecretKey"),
    "prefix": os.environ.get("SEPAY_PREFIX", "ET")
}

# ── PLANS ──────────────────────────────────────────────────────────────────────
PLANS = {
    "monthly":  {"name": "Gói Tháng",    "days": 30,  "amount": 29000},
    "yearly":   {"name": "Gói Năm",      "days": 365, "amount": 216000},
    "lifetime": {"name": "Gói Trọn Đời", "days": -1,  "amount": 499000},
}

PLAN_NAME_TO_CODE = {v["name"]: k for k, v in PLANS.items()}

# ── HELPERS ────────────────────────────────────────────────────────────────────

def to_utc_datetime(dt):
    """Chuyển đổi các loại datetime/timestamp về UTC datetime chuẩn"""
    if dt is None:
        return None
    # Xử lý Firestore Timestamp
    if hasattr(dt, 'to_datetime'):
        dt = dt.to_datetime()
    # Đảm bảo có timezone info
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)

def get_plan_code(plan_input: str) -> str:
    """Map cả code và tên sang code chuẩn"""
    if plan_input in PLANS:
        return plan_input
    return PLAN_NAME_TO_CODE.get(plan_input, "monthly")

def calculate_expiry(plan_code: str, current_expiry=None, cumulative=True):
    """
    Tính ngày hết hạn mới.
    - cumulative=True: Cộng dồn vào ngày hết hạn cũ (dùng cho RENEW).
    - cumulative=False: Tính từ thời điểm hiện tại (dùng cho UPGRADE/NEW).
    """
    if plan_code == "lifetime":
        return None

    now = datetime.now(timezone.utc)
    start = now

    if cumulative and current_expiry:
        try:
            exp_dt = to_utc_datetime(current_expiry)
            if exp_dt > now:
                start = exp_dt
        except Exception:
            pass

    days = PLANS[plan_code]["days"]
    return start + timedelta(days=days)

def get_transaction_type(user_data: dict, new_plan_code: str) -> str:
    """Xác định loại: new | renew | upgrade | downgrade"""
    current_plan = user_data.get("plan")
    is_premium   = user_data.get("isPremium", False)

    if not is_premium or not current_plan:
        return "new"
    if current_plan == new_plan_code:
        return "renew"

    rank = {"monthly": 1, "yearly": 2, "lifetime": 3}
    if rank.get(new_plan_code, 0) > rank.get(current_plan, 0):
        return "upgrade"
    return "downgrade"

def calculate_upgrade_price(user_data: dict, new_plan_code: str) -> dict:
    """
    Tính toán số tiền cần trả thêm khi nâng cấp gói (pro-rated).
    Công thức: 
    - remainingDays = premiumExpiry - today
    - dailyRate = originalPrice_gói_cũ / totalDays_gói_cũ
    - creditAmount = remainingDays * dailyRate
    - finalPrice = price_gói_mới - creditAmount
    """
    new_plan_info = PLANS.get(new_plan_code)
    original_price = new_plan_info["amount"]
    
    current_plan = user_data.get("plan")
    is_premium = user_data.get("isPremium", False)
    expiry = user_data.get("premiumExpiry")
    
    # Nếu không phải upgrade hoặc không có gói cũ còn hạn -> trả full
    if not is_premium or not current_plan or current_plan == new_plan_code or not expiry:
        return {
            "originalPrice": original_price,
            "creditAmount": 0,
            "finalPrice": original_price,
            "daysLeft": 0,
            "previousPlan": current_plan
        }
        
    # Tính số ngày còn lại
    now = datetime.now(timezone.utc)
    exp_dt = to_utc_datetime(expiry)
    
    if exp_dt <= now:
        return {
            "originalPrice": original_price,
            "creditAmount": 0,
            "finalPrice": original_price,
            "daysLeft": 0,
            "previousPlan": current_plan
        }
        
    # Tính toán chính xác theo yêu cầu
    days_left = (exp_dt - now).days
    if days_left < 0: days_left = 0
    
    current_plan_info = PLANS.get(current_plan)
    total_days = current_plan_info["days"]
    
    if total_days <= 0: # Trường hợp lifetime
        credit_amount = 0
    else:
        # dailyRate = price / total_days
        # creditAmount = days_left * dailyRate
        daily_rate = current_plan_info["amount"] / total_days
        credit_amount = int(days_left * daily_rate)
        
    final_price = max(1000, original_price - credit_amount) # Tối thiểu 1000đ
    
    return {
        "originalPrice": original_price,
        "creditAmount": credit_amount,
        "finalPrice": final_price,
        "daysLeft": days_left,
        "previousPlan": current_plan
    }

def upgrade_user_premium(db, user_id: str, plan_code: str) -> dict:
    """Cập nhật Firestore user"""
    user_ref  = db.collection("users").document(user_id)
    user_doc  = user_ref.get()

    user_data    = user_doc.to_dict() if user_doc.exists else {}
    current_plan = user_data.get("plan")
    prev_expiry  = user_data.get("premiumExpiry")

    transaction_type = get_transaction_type(user_data, plan_code)
    
    # UPGRADE -> KHÔNG cộng dồn, tính từ hôm nay.
    # RENEW   -> CÓ cộng dồn.
    is_cumulative = (transaction_type == "renew")
    new_expiry = calculate_expiry(plan_code, prev_expiry, cumulative=is_cumulative)

    # Xác định start_date cho transaction log
    now = datetime.now(timezone.utc)
    premium_from = now
    if is_cumulative and prev_expiry:
        exp_dt = to_utc_datetime(prev_expiry)
        if exp_dt and exp_dt > now:
            premium_from = exp_dt

    update_data = {
        "isPremium":          True,
        "subscriptionStatus": "active",
        "plan":               plan_code,
        "premiumAt":          firestore.SERVER_TIMESTAMP,
        "premiumStart":       firestore.SERVER_TIMESTAMP,
        "premiumExpiry":      new_expiry,
    }
    user_ref.set(update_data, merge=True)

    return {
        "transaction_type": transaction_type,
        "previous_plan":    current_plan,
        "premium_from":     premium_from,
        "premium_to":       new_expiry,
    }

def build_transaction_doc(method: str, user_id: str, plan_code: str, amount: int, upgrade_info: dict, extra: dict = None, pricing_detail: dict = None) -> dict:
    """Tạo cấu trúc document transaction chuẩn"""
    plan_info = PLANS.get(plan_code, PLANS["monthly"])
    doc = {
        "userId":          user_id,
        "method":          method,
        "status":          "success",
        "timestamp":       firestore.SERVER_TIMESTAMP,
        "planCode":        plan_code,
        "planName":        plan_info["name"],
        "amount":          amount,
        "transactionType": upgrade_info.get("transaction_type"),
        "previousPlan":    upgrade_info.get("previous_plan"),
        "premiumFrom":     upgrade_info.get("premium_from"), # Sử dụng giá trị từ upgrade_info
        "premiumTo":       upgrade_info.get("premium_to"),   # Sử dụng giá trị từ upgrade_info
        "paymentDetail":   extra
    }
    if pricing_detail:
        doc.update({
            "originalPrice": pricing_detail.get("originalPrice"),
            "creditAmount":  pricing_detail.get("creditAmount"),
        })
    return doc

# ══════════════════════════════════════════════════════════════════════════════
# MOMO
# ══════════════════════════════════════════════════════════════════════════════

def create_momo_signature(payload: dict) -> str:
    raw = (
        f"accessKey={MOMO_CONFIG['accessKey']}&"
        f"amount={payload['amount']}&"
        f"extraData={payload['extraData']}&"
        f"ipnUrl={MOMO_CONFIG['ipnUrl']}&"
        f"orderId={payload['orderId']}&"
        f"orderInfo={payload['orderInfo']}&"
        f"partnerCode={MOMO_CONFIG['partnerCode']}&"
        f"redirectUrl={MOMO_CONFIG['redirectUrl']}&"
        f"requestId={payload['requestId']}&"
        f"requestType={MOMO_CONFIG['requestType']}"
    )
    return hmac.new(MOMO_CONFIG['secretKey'].encode(), raw.encode(), hashlib.sha256).hexdigest()

def verify_momo_signature(data: dict) -> bool:
    try:
        raw = (
            f"accessKey={MOMO_CONFIG['accessKey']}&"
            f"amount={data['amount']}&"
            f"extraData={data['extraData']}&"
            f"message={data['message']}&"
            f"orderId={data['orderId']}&"
            f"orderInfo={data['orderInfo']}&"
            f"orderType={data['orderType']}&"
            f"partnerCode={data['partnerCode']}&"
            f"payType={data['payType']}&"
            f"requestId={data['requestId']}&"
            f"responseTime={data['responseTime']}&"
            f"resultCode={data['resultCode']}&"
            f"transId={data['transId']}"
        )
        expected = hmac.new(MOMO_CONFIG['secretKey'].encode(), raw.encode(), hashlib.sha256).hexdigest()
        return expected == data.get('signature')
    except Exception as e:
        logging.error(f"[MoMo] Signature verify error: {e}")
        return False

@payment_bp.route('/upgrade-preview/<user_id>/<new_plan>', methods=['GET'])
def upgrade_preview(user_id, new_plan):
    try:
        db = firestore.client()
        user_doc = db.collection("users").document(user_id).get()
        if not user_doc.exists:
            return jsonify({"success": False, "error": "User not found"}), 404
            
        user_data = user_doc.to_dict()
        plan_code = get_plan_code(new_plan)
        
        pricing = calculate_upgrade_price(user_data, plan_code)
        return jsonify({"success": True, **pricing})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/momo-payment', methods=['POST'])
def create_momo_payment():
    try:
        data       = request.get_json()
        user_id    = data.get("userId")
        plan_input = data.get("plan")
        
        plan_code  = get_plan_code(plan_input)
        
        db = firestore.client()
        user_data = db.collection("users").document(user_id).get().to_dict()
        pricing = calculate_upgrade_price(user_data, plan_code)
        
        order_id   = str(uuid.uuid4())
        request_id = str(uuid.uuid4())
        extra_data = json.dumps({
            "user_id": user_id, 
            "plan": plan_code,
            "originalPrice": pricing["originalPrice"],
            "creditAmount": pricing["creditAmount"]
        })

        payload = {
            "partnerCode": MOMO_CONFIG["partnerCode"],
            "accessKey":   MOMO_CONFIG["accessKey"],
            "requestId":   request_id,
            "amount":      str(pricing["finalPrice"]),
            "orderId":     order_id,
            "orderInfo":   data.get("orderInfo", f"EduTalk {PLANS[plan_code]['name']}"),
            "redirectUrl": MOMO_CONFIG["redirectUrl"],
            "ipnUrl":      MOMO_CONFIG["ipnUrl"],
            "requestType": MOMO_CONFIG["requestType"],
            "extraData":   extra_data,
            "lang":        "vi"
        }
        payload["signature"] = create_momo_signature(payload)

        response = requests.post(MOMO_CONFIG["endpoint"], json=payload, timeout=15)
        res_data = response.json()

        if res_data.get("resultCode") == 0:
            return jsonify({
                "success":  True,
                "payUrl":   res_data.get("payUrl"),
                "deeplink": res_data.get("deeplink"),
                "qrCode":   res_data.get("qrCodeUrl"),
                "orderId":  order_id
            })
        return jsonify({"success": False, "error": res_data.get("message")}), 400
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/payment-callback', methods=['POST'])
def momo_callback():
    try:
        data = request.get_json()
        if not verify_momo_signature(data):
            return jsonify({"status": "error", "message": "Invalid signature"}), 400

        if str(data.get("resultCode")) == "0":
            extra      = json.loads(data.get("extraData", "{}"))
            user_id    = extra.get("user_id")
            plan_code  = extra.get("plan")
            
            if user_id:
                db = firestore.client()
                upgrade_info = upgrade_user_premium(db, user_id, plan_code)
                
                payment_detail = {
                    "transId":     data.get("transId"),
                    "orderId":     data.get("orderId"),
                    "orderInfo":   data.get("orderInfo"),
                    "payType":     data.get("payType"),
                    "partnerCode": data.get("partnerCode"),
                    "message":     data.get("message")
                }
                
                trans_doc = build_transaction_doc(
                    method       = "momo",
                    user_id      = user_id,
                    plan_code    = plan_code,
                    amount       = int(data.get("amount", 0)),
                    upgrade_info = upgrade_info,
                    extra        = payment_detail,
                    pricing_detail = {
                        "originalPrice": extra.get("originalPrice"),
                        "creditAmount": extra.get("creditAmount")
                    }
                )
                db.collection("transactions").document(data.get("orderId")).set(trans_doc)
        
        return jsonify({"status": "ok"}), 200
    except Exception as e:
        return jsonify({"status": "error", "error": str(e)}), 500

# ══════════════════════════════════════════════════════════════════════════════
# BANK (SePay)
# ══════════════════════════════════════════════════════════════════════════════

@payment_bp.route('/create-bank-payment', methods=['POST'])
def create_bank_payment():
    try:
        data       = request.get_json()
        user_id    = data.get("userId")
        plan_input = data.get("plan")
        
        plan_code  = get_plan_code(plan_input)
        
        db = firestore.client()
        user_data = db.collection("users").document(user_id).get().to_dict()
        pricing = calculate_upgrade_price(user_data, plan_code)
        
        payment_code_numeric = ''.join(random.choices(string.digits, k=6))
        
        db.collection("transactions").document(payment_code_numeric).set({
            "userId":      user_id,
            "method":      "bank",
            "status":      "pending",
            "planCode":    plan_code,
            "planName":    PLANS[plan_code]["name"],
            "amount":      pricing["finalPrice"],
            "originalPrice": pricing["originalPrice"],
            "creditAmount": pricing["creditAmount"],
            "paymentCode": f"{SEPAY_CONFIG['prefix']}{payment_code_numeric}",
            "timestamp":   firestore.SERVER_TIMESTAMP
        })
        
        return jsonify({
            "success":     True,
            "paymentCode": f"{SEPAY_CONFIG['prefix']}{payment_code_numeric}",
            "amount":      pricing["finalPrice"],
            "orderId":     payment_code_numeric
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/sepay-webhook', methods=['POST'])
def sepay_webhook():
    try:
        auth_header = request.headers.get("Authorization", "")
        api_key     = auth_header.replace("Apikey ", "").strip()
        if api_key != SEPAY_CONFIG["apiKey"]:
            return jsonify({"status": "error", "message": "Unauthorized"}), 403
            
        data    = request.get_json()
        content = data.get("content", "")
        amount_received = float(data.get("transferAmount", 0))
        
        # Bóc tách lấy phần SỐ từ nội dung ETxxxxxx
        match = re.search(rf"{SEPAY_CONFIG['prefix']}(\d{{6,8}})", content.upper())
        if not match:
            return jsonify({"success": True, "status": "ignored"}), 200
            
        payment_id = match.group(1) 
        db = firestore.client()
        trans_ref  = db.collection("transactions").document(payment_id)
        trans_doc  = trans_ref.get()
        
        if not trans_doc.exists:
            return jsonify({"success": False, "message": "Transaction not found"}), 404
            
        trans_data = trans_doc.to_dict()
        if trans_data['status'] == 'success':
            return jsonify({"success": True, "status": "already_processed"}), 200
            
        expected_amount = trans_data.get('amount', 0)
        if amount_received < expected_amount * 0.9:
            return jsonify({"success": False, "message": "Amount mismatch"}), 400
             
        upgrade_info = upgrade_user_premium(db, trans_data['userId'], trans_data['planCode'])
        
        payment_detail = {
            "gateway":         data.get("gateway"),
            "accountNumber":   data.get("accountNumber"),
            "subAccount":      data.get("subAccount"),
            "transferAmount":  data.get("transferAmount"),
            "referenceCode":   data.get("referenceCode"),
            "transactionDate": data.get("transactionDate"),
            "content":         content,
            "sepayId":         data.get("id")
        }
        
        trans_ref.update({
            "status":          "success",
            "transactionType": upgrade_info["transaction_type"],
            "previousPlan":    upgrade_info["previous_plan"],
            "premiumFrom":     upgrade_info["premium_from"],
            "premiumTo":       upgrade_info["premium_to"],
            "paymentDetail":   payment_detail
        })
        
        return jsonify({"success": True, "status": "ok"}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ── STATUS ──────────────────────────────────────────────────────────────────

@payment_bp.route('/check-status/<user_id>', methods=['GET'])
def check_premium_status(user_id):
    try:
        db = firestore.client()
        user_ref = db.collection("users").document(user_id)
        user_doc = user_ref.get()
        
        if not user_doc.exists:
            return jsonify({"success": False, "error": "User not found"}), 404
            
        user_data  = user_doc.to_dict()
        is_premium = user_data.get("isPremium", False)
        plan_code  = user_data.get("plan")
        expiry     = user_data.get("premiumExpiry")
        
        now = datetime.now(timezone.utc)
        
        # Kiểm tra hết hạn
        if is_premium and plan_code != 'lifetime' and expiry:
            exp_dt = to_utc_datetime(expiry)
            if exp_dt <= now:
                user_ref.update({
                    "isPremium":          False,
                    "plan":               None,
                    "subscriptionStatus": "expired"
                })
                return jsonify({
                    "success":    True,
                    "isPremium":  False,
                    "expired":    True,
                    "message":    "Premium expired"
                })
        
        days_left = None
        if is_premium:
            if plan_code == 'lifetime':
                days_left = -1
            elif expiry:
                exp_dt = to_utc_datetime(expiry)
                days_left = (exp_dt - now).days

        return jsonify({
            "success":   True, 
            "isPremium": is_premium,
            "plan":      plan_code,
            "planName":  PLANS.get(plan_code, {}).get("name") if plan_code else None,
            "daysLeft":  days_left,
            "expiry":    expiry.isoformat() if hasattr(expiry, 'isoformat') else None
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
