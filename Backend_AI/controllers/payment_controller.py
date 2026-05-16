import uuid
import hashlib
import hmac
import requests
import json
from flask import Blueprint, request, jsonify
from firebase_admin import firestore

payment_bp = Blueprint('payment', __name__)

# ── MoMo Sandbox Settings ─────────────────────────────────────────────────
MOMO_PARTNER_CODE = "MOMOBKUN20180529"
MOMO_ACCESS_KEY   = "klm05TvNBzhg7h7j"
MOMO_SECRET_KEY   = "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa"
MOMO_ENDPOINT = "https://test-payment.momo.vn/v2/gateway/api/create"

@payment_bp.route('/momo-payment', methods=['POST', 'GET'], strict_slashes=False)
def create_momo_payment():
    if request.method == 'GET':
        return "Momo Payment endpoint is active. Use POST to create a payment link."
    try:
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "message": "Missing JSON body"}), 400
            
        # Ép kiểu dữ liệu chuẩn
        amount = str(data.get('amount', '0')).split('.')[0] 
        user_id = str(data.get('user_id', ''))
        order_id = str(data.get('orderId', uuid.uuid4()))
        order_info = str(data.get('orderInfo', "Thanh toan EduTalk"))
        request_id = str(data.get('requestId', order_id))
        extra_data = user_id if user_id else ""
        
        redirect_url = "https://edutalk-7ndf.onrender.com/payment-callback"
        ipn_url = "https://edutalk-7ndf.onrender.com/payment-callback"
        request_type = "captureWallet"

        # 1. Tạo chuỗi ký tự signature (Alphabet order)
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

        # 3. Payload gửi sang MoMo
        payload = {
            "partnerCode": MOMO_PARTNER_CODE,
            "partnerName": "EduTalk",
            "storeId": MOMO_PARTNER_CODE,
            "requestId": request_id,
            "amount": int(amount),
            "orderId": order_id,
            "orderInfo": order_info,
            "redirectUrl": redirect_url,
            "ipnUrl": ipn_url,
            "lang": "vi",
            "extraData": extra_data,
            "requestType": request_type,
            "signature": signature
        }

        print(f"Payload gửi MoMo: {json.dumps(payload)}")
        response = requests.post(MOMO_ENDPOINT, json=payload)
        res_data = response.json()
        print(f"MoMo trả về: {res_data}")

        if res_data.get('resultCode') == 0:
            return jsonify({
                "success":    True,
                "payUrl":     res_data.get('payUrl'),
                "deeplink":   res_data.get('deeplink'),
                "qrCodeUrl":  res_data.get('qrCodeUrl'),
            })
        else:
            return jsonify({
                "success": False,
                "message": res_data.get('message', "Lỗi từ MoMo"),
                "details": res_data
            }), 400

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/payment-callback', methods=['POST', 'GET'], strict_slashes=False)
def momo_callback():
    if request.method == 'GET':
        return "Momo Callback endpoint is active. Use POST to simulate a callback."
    try:
        data = request.get_json()
        print("MoMo Callback Data:", data)
        
        result_code = data.get('resultCode')
        user_id = data.get('extraData') 
        
        if result_code == 0 and user_id:
            db = firestore.client()
            user_ref = db.collection('users').document(user_id)
            user_ref.update({
                'isPremium': True,
                'premiumAt': firestore.SERVER_TIMESTAMP
            })
            return jsonify({"success": True, "message": "Updated Premium"}), 200
        
        return jsonify({"success": False, "message": "Payment failed or no user_id"}), 400
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
