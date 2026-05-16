import uuid
import hashlib
import hmac
import requests
import json
from flask import Blueprint, request, jsonify
from firebase_admin import firestore

payment_bp = Blueprint('payment', __name__)

#MoMo Sandbox Settings
MOMO_PARTNER_CODE = "MOMOBKUN20180529"
MOMO_ACCESS_KEY   = "klm05TvNBzhg7h7j"
MOMO_SECRET_KEY   = "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa"
MOMO_ENDPOINT     = "https://test-payment.momo.vn/v2/gateway/api/create"
BACKEND_URL       = "https://edutalk-7ndf.onrender.com"

#Cấu hình các gói Premium
PLANS = {
    'monthly':  {'name': 'Gói Tháng',    'amount': 29000,  'duration_days': 30},
    'yearly':   {'name': 'Gói Năm',      'amount': 216000, 'duration_days': 365},
    'lifetime': {'name': 'Gói Trọn Đời', 'amount': 499000, 'duration_days': -1},
}

#TẠO ĐƠN THANH TOÁN
@payment_bp.route('/momo-payment', methods=['POST', 'GET'], strict_slashes=False)
def create_momo_payment():
    if request.method == 'GET':
        return "Momo Payment endpoint is active. Use POST to create a payment link."
    try:
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "message": "Missing JSON body"}), 400

        user_id = str(data.get('user_id', ''))
        plan    = str(data.get('plan', ''))

        # Validate plan
        if plan not in PLANS:
            return jsonify({"success": False, "message": f"Plan không hợp lệ. Chọn: {list(PLANS.keys())}"}), 400
        if not user_id:
            return jsonify({"success": False, "message": "Thiếu user_id"}), 400

        plan_info  = PLANS[plan]
        amount     = str(plan_info['amount'])
        order_id   = f"EDUTALK_{plan.upper()}_{uuid.uuid4().hex[:8].upper()}"
        request_id = order_id
        order_info = f"EduTalk {plan_info['name']}"

        # extra_data lưu user_id + plan để callback dùng
        extra_data   = json.dumps({"user_id": user_id, "plan": plan}, separators=(',', ':'))
        redirect_url = f"{BACKEND_URL}/payment-callback"
        ipn_url      = f"{BACKEND_URL}/payment-callback"
        request_type = "captureWallet"

        raw_signature = (
            f"accessKey={MOMO_ACCESS_KEY}&"
            f"amount={amount}&"
            f"extraData={extra_data}&"
            f"ipnUrl={ipn_url}&"
            f"orderId={order_id}&"
            f"orderInfo={order_info}&"
            f"partnerCode={MOMO_PARTNER_CODE}&"
            f"redirectUrl={redirect_url}&"
            f"requestId={request_id}&"
            f"requestType={request_type}"
        )

        signature = hmac.new(
            MOMO_SECRET_KEY.encode('utf-8'),
            raw_signature.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()

        payload = {
            "partnerCode": MOMO_PARTNER_CODE,
            "partnerName": "EduTalk",
            "storeId":     MOMO_PARTNER_CODE,
            "requestId":   request_id,
            "amount":      int(amount),
            "orderId":     order_id,
            "orderInfo":   order_info,
            "redirectUrl": redirect_url,
            "ipnUrl":      ipn_url,
            "lang":        "vi",
            "extraData":   extra_data,
            "requestType": request_type,
            "signature":   signature
        }

        print(f"[Payment] Tạo đơn: {order_id} | Plan: {plan} | Amount: {amount}")
        response = requests.post(MOMO_ENDPOINT, json=payload)
        res_data = response.json()
        print(f"[Payment] MoMo response: resultCode={res_data.get('resultCode')}")

        if res_data.get('resultCode') == 0:
            return jsonify({
                "success":   True,
                "orderId":   order_id,
                "plan":      plan,
                "amount":    int(amount),
                "payUrl":    res_data.get('payUrl'),
                "deeplink":  res_data.get('deeplink'),
                "qrCodeUrl": res_data.get('qrCodeUrl'),
            })
        else:
            return jsonify({
                "success": False,
                "message": res_data.get('message', "Lỗi từ MoMo"),
            }), 400

    except Exception as e:
        print(f"[Payment] Error: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


#CALLBACK TỪ MOMO
@payment_bp.route('/payment-callback', methods=['POST', 'GET'], strict_slashes=False)
def momo_callback():
    if request.method == 'GET':
        return "Momo Callback endpoint is active."
    try:
        data        = request.get_json()
        result_code = data.get('resultCode')
        extra_data  = data.get('extraData', '')

        print(f"[Callback] resultCode={result_code} | extraData={extra_data}")

        if result_code == 0 and extra_data:
            # Parse extra_data
            try:
                extra   = json.loads(extra_data)
                user_id = extra.get('user_id')
                plan    = extra.get('plan', 'monthly')
            except Exception:
                user_id = extra_data  # fallback: test thủ công qua Postman
                plan    = 'monthly'

            if not user_id:
                return jsonify({"success": False, "message": "Thiếu user_id"}), 400

            plan_info = PLANS.get(plan, PLANS['monthly'])
            db        = firestore.client()

            # Cập nhật user → isPremium
            db.collection('users').document(user_id).set({
                'isPremium':    True,
                'plan':         plan,
                'planName':     plan_info['name'],
                'durationDays': plan_info['duration_days'],
                'premiumAt':    firestore.SERVER_TIMESTAMP,
            }, merge=True)

            # Lưu lịch sử giao dịch
            db.collection('transactions').add({
                'user_id':   user_id,
                'plan':      plan,
                'planName':  plan_info['name'],
                'amount':    data.get('amount'),
                'orderId':   data.get('orderId'),
                'transId':   data.get('transId'),
                'status':    'success',
                'createdAt': firestore.SERVER_TIMESTAMP,
            })

            print(f"[Callback]  User {user_id} upgraded → {plan}")
            return jsonify({"success": True, "message": f"Upgraded to {plan}"}), 200

        print(f"[Callback]  Payment failed: resultCode={result_code}")
        return jsonify({"success": False, "message": "Payment failed"}), 400

    except Exception as e:
        print(f"[Callback] Error: {e}")
        return jsonify({"success": False, "error": str(e)}), 500