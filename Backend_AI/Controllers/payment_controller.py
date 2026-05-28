import hmac
import hashlib
import uuid
import requests
import logging
import json
import random
import string
import re
from flask import Blueprint, request, jsonify
from firebase_admin import firestore

# Khởi tạo Blueprint cho Payment
payment_bp = Blueprint('payment', __name__)

# Cấu hình MoMo
MOMO_CONFIG = {
    "partnerCode": "MOMOBKUN20180529",
    "accessKey": "klm05TvNBzhg7h7j",
    "secretKey": "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa",
    "endpoint": "https://test-payment.momo.vn/v2/gateway/api/create",
    "redirectUrl": "edutalk://payment-result",
    "ipnUrl": "https://edutalk-7ndf.onrender.com/payment/payment-callback",
    "requestType": "captureWallet"
}

# Cấu hình SePay (Thanh toán Ngân hàng)
SEPAY_CONFIG = {
    "apiKey": "EduTalk2025SecretKey", # Mã bảo mật đã đặt trên SePay
    "prefix": "ET"
}

def create_momo_signature(payload):
    raw_signature = (
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
    h = hmac.new(MOMO_CONFIG['secretKey'].encode('utf-8'),
                 raw_signature.encode('utf-8'), digestmod=hashlib.sha256)
    return h.hexdigest()

def verify_momo_signature(data):
    try:
        raw_signature = (
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
        h = hmac.new(MOMO_CONFIG['secretKey'].encode('utf-8'),
                     raw_signature.encode('utf-8'), digestmod=hashlib.sha256)
        return h.hexdigest() == data.get('signature')
    except Exception as e:
        logging.error(f"Error verifying signature: {str(e)}")
        return False

from datetime import datetime, timedelta, timezone

def calculate_expiry(plan_type, current_expiry=None):
    now = datetime.now(timezone.utc)
    # Nếu đang còn hạn, cộng thêm vào ngày hết hạn hiện tại
    start_date = now
    if current_expiry and current_expiry > now:
        start_date = current_expiry
        
    if plan_type == 'monthly':
        return start_date + timedelta(days=30)
    elif plan_type == 'yearly':
        return start_date + timedelta(days=365)
    elif plan_type == 'lifetime':
        return None  # Vĩnh viễn
    return now + timedelta(days=30) # Default

def upgrade_user_premium(db, user_id, plan_name):
    # Map tên gói sang mã gói
    plan_map = {
        'Gói Tháng': 'monthly',
        'Gói Năm': 'yearly',
        'Gói Trọn Đời': 'lifetime'
    }
    plan_type = plan_map.get(plan_name, 'monthly')
    
    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()
    
    current_expiry = None
    if user_doc.exists:
        data = user_doc.to_dict()
        current_expiry = data.get("premiumExpiry")
        
    new_expiry = calculate_expiry(plan_type, current_expiry)
    
    user_ref.set({
        "isPremium": True,
        "subscriptionStatus": "active",
        "plan": plan_type,
        "currentPlan": plan_name,
        "premiumAt": firestore.SERVER_TIMESTAMP,
        "premiumStart": firestore.SERVER_TIMESTAMP,
        "premiumExpiry": new_expiry
    }, merge=True)
    return True

@payment_bp.route('/momo-payment', methods=['POST'])
def create_momo_payment():
    try:
        data = request.get_json()
        amount = data.get("amount")
        order_info = data.get("orderInfo")
        user_id = data.get("userId")
        plan = data.get("plan")

        order_id = str(uuid.uuid4())
        request_id = str(uuid.uuid4())
        
        extra_data = json.dumps({"user_id": user_id, "plan": plan})

        payload = {
            "partnerCode": MOMO_CONFIG["partnerCode"],
            "accessKey": MOMO_CONFIG["accessKey"],
            "requestId": request_id,
            "amount": str(amount),
            "orderId": order_id,
            "orderInfo": order_info,
            "redirectUrl": MOMO_CONFIG["redirectUrl"],
            "ipnUrl": MOMO_CONFIG["ipnUrl"],
            "requestType": MOMO_CONFIG["requestType"],
            "extraData": extra_data,
            "lang": "vi"
        }
        
        payload["signature"] = create_momo_signature(payload)
        
        response = requests.post(MOMO_CONFIG["endpoint"], json=payload)
        response_data = response.json()
        
        if response.status_code == 200 and response_data.get("resultCode") == 0:
            return jsonify({
                "deeplink": response_data.get("deeplink"),
                "payUrl": response_data.get("payUrl"),
                "orderId": order_id
            })
        else:
            return jsonify({"success": False, "error": response_data.get("message", "Error from MoMo")}), 400
            
    except Exception as e:
        logging.error(f"Error creating MoMo payment: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/payment-callback', methods=['POST'])
def payment_callback():
    try:
        data = request.get_json()
        logging.info(f"MoMo Callback received: {data}")
        
        if not verify_momo_signature(data):
            logging.error("Invalid MoMo signature!")
            return jsonify({"status": "error", "message": "Invalid signature"}), 400

        if str(data.get("resultCode")) == "0":
            extra_data_str = data.get("extraData")
            if extra_data_str:
                extra_data = json.loads(extra_data_str)
                user_id = extra_data.get("user_id")
                plan = extra_data.get("plan")
                
                if user_id:
                    db = firestore.client()
                    upgrade_user_premium(db, user_id, plan)
                    
                    db.collection("transactions").add({
                        "amount": int(data.get("amount")),
                        "message": data.get("message"),
                        "method": "momo",
                        "orderId": data.get("orderId"),
                        "plan": plan,
                        "status": "success",
                        "timestamp": firestore.SERVER_TIMESTAMP,
                        "transId": int(data.get("transId")),
                        "userId": user_id
                    })
                    logging.info(f"Successfully upgraded user {user_id} and recorded transaction")
        
        return jsonify({"status": "ok"}), 200
        
    except Exception as e:
        logging.error(f"Error processing MoMo callback: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/create-bank-payment', methods=['POST'])
def create_bank_payment():
    try:
        data = request.get_json()
        user_id = data.get("userId")
        amount = data.get("amount")
        plan = data.get("plan")
        
        payment_code = ''.join(random.choices(string.digits, k=6))
        
        db = firestore.client()
        db.collection("transactions").document(payment_code).set({
            "amount": int(amount),
            "method": "bank",
            "plan": plan,
            "status": "pending",
            "userId": user_id,
            "paymentCode": payment_code,
            "timestamp": firestore.SERVER_TIMESTAMP
        })
        
        return jsonify({
            "success": True,
            "paymentCode": f"{SEPAY_CONFIG['prefix']}{payment_code}",
            "amount": amount,
            "orderId": payment_code
        })
    except Exception as e:
        logging.error(f"Error creating bank payment: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/check-status/<user_id>', methods=['GET'])
def check_premium_status(user_id):
    try:
        db = firestore.client()
        user_ref = db.collection("users").document(user_id)
        user_doc = user_ref.get()
        
        if not user_doc.exists:
            return jsonify({"success": False, "error": "User not found"}), 404
            
        user_data = user_doc.to_dict()
        is_premium = user_data.get("isPremium", False)
        plan = user_data.get("plan")
        expiry = user_data.get("premiumExpiry")
        
        # Nếu đang là premium và không phải trọn đời, kiểm tra hết hạn
        if is_premium and plan != 'lifetime' and expiry:
            # Convert Firestore timestamp to datetime
            if hasattr(expiry, 'timestamp'):
                expiry_dt = expiry
            else:
                # Handle potential other formats if any
                expiry_dt = expiry
                
            from datetime import datetime, timezone
            now = datetime.now(timezone.utc)
            
            if expiry_dt <= now:
                # Hết hạn -> Cập nhật Firestore
                user_ref.update({
                    "isPremium": False,
                    "plan": None,
                    "currentPlan": None
                })
                return jsonify({
                    "success": True, 
                    "isPremium": False, 
                    "message": "Premium expired",
                    "expired": True
                })
        
        return jsonify({
            "success": True, 
            "isPremium": is_premium,
            "plan": plan,
            "expiry": expiry.isoformat() if expiry and hasattr(expiry, 'isoformat') else None
        })
        
    except Exception as e:
        logging.error(f"Error checking premium status: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/sepay-webhook', methods=['POST'])
def sepay_webhook():
    try:
        # 1. Xác thực API Key từ Header Authorization (SePay gửi dưới dạng "Apikey LDSZGQ...")
        auth_header = request.headers.get("Authorization", "")
        api_key = auth_header.replace("Apikey ", "").strip()
        
        if api_key != SEPAY_CONFIG["apiKey"]:
            logging.warning(f"Unauthorized Webhook attempt with key: {api_key}")
            return jsonify({"status": "error", "message": "Unauthorized"}), 403
            
        data = request.get_json()
        logging.info(f"SePay Webhook received: {data}")
        
        content = data.get("content", "")
        # SePay dùng trường 'transferAmount' cho số tiền nhận được
        amount_received = float(data.get("transferAmount", 0))
        
        # 2. Phân tích nội dung để tìm paymentCode (Ví dụ: ET123456)
        if SEPAY_CONFIG['prefix'].upper() not in content.upper():
             return jsonify({"success": True, "status": "ignored", "message": "Invalid prefix"}), 200
             
        # Tìm chính xác 6-8 chữ số trong nội dung chuyển khoản
        match = re.search(r'\d{6,8}', content)
        if not match:
            return jsonify({"success": True, "status": "ignored", "message": "Payment code not found"}), 200
            
        payment_code = match.group(0)
        
        db = firestore.client()
        transaction_ref = db.collection("transactions").document(payment_code)
        transaction_doc = transaction_ref.get()
        
        if not transaction_doc.exists:
            return jsonify({"success": False, "status": "error", "message": "Transaction not found"}), 404
            
        transaction_data = transaction_doc.to_dict()
        
        if transaction_data['status'] == 'success':
            return jsonify({"success": True, "status": "ok", "message": "Already processed"}), 200
            
        if amount_received < transaction_data['amount']:
             return jsonify({"success": False, "status": "error", "message": "Amount mismatch"}), 400
             
        user_id = transaction_data['userId']
        plan_name = transaction_data['plan'] # Trong transaction lưu planName như 'Gói Tháng'
        
        db = firestore.client()
        upgrade_user_premium(db, user_id, plan_name)
        
        transaction_ref.update({
            "status": "success",
            "timestamp": firestore.SERVER_TIMESTAMP,
            "sepayData": data
        })
        
        logging.info(f"Successfully upgraded user {user_id} via Bank Transfer (SePay)")
        return jsonify({"success": True, "status": "ok"}), 200
        
    except Exception as e:
        logging.error(f"Error processing SePay webhook: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500
