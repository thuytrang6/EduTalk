import hmac
import hashlib
import uuid
import requests
import logging
from flask import Blueprint, request, jsonify
from firebase_admin import firestore

# Khởi tạo Blueprint cho Payment
payment_bp = Blueprint('payment', __name__)

# Cấu hình MoMo (Nên đưa vào biến môi trường trong thực tế)
MOMO_CONFIG = {
    "partnerCode": "MOMOBKUN20180529",
    "accessKey": "klm05TvNBzhg7h7j",
    "secretKey": "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa",
    "endpoint": "https://test-payment.momo.vn/v2/gateway/api/create",
    "redirectUrl": "edutalk://payment-result",
    "ipnUrl": "https://edutalk-7ndf.onrender.com/payment-callback",
    "requestType": "captureWallet"
}

def create_momo_signature(payload):
    # MoMo yêu cầu data theo thứ tự bảng chữ cái hoặc đúng list tham số quy định
    raw_signature = f"accessKey={MOMO_CONFIG['accessKey']}&amount={payload['amount']}&extraData={payload['extraData']}&ipnUrl={MOMO_CONFIG['ipnUrl']}&orderId={payload['orderId']}&orderInfo={payload['orderInfo']}&partnerCode={MOMO_CONFIG['partnerCode']}&redirectUrl={MOMO_CONFIG['redirectUrl']}&requestId={payload['requestId']}&requestType={MOMO_CONFIG['requestType']}"
    h = hmac.new(MOMO_CONFIG['secretKey'].encode('utf-8'), raw_signature.encode('utf-8'), digestmod=hashlib.sha256)
    return h.hexdigest()

@payment_bp.route('/momo-payment', methods=['POST'])
def create_momo_payment():
    try:
        data = request.get_json()
        amount = data.get("amount")
        order_info = data.get("orderInfo")
        user_id = data.get("userId")
        
        order_id = str(uuid.uuid4())
        request_id = str(uuid.uuid4())
        
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
            "extraData": user_id, # Lưu userId vào extraData để nhận lại ở callback
            "lang": "vi"
        }
        
        payload["signature"] = create_momo_signature(payload)
        
        response = requests.post(MOMO_CONFIG["endpoint"], json=payload)
        response_data = response.json()
        
        if response.status_code == 200 and response_data.get("resultCode") == 0:
            return jsonify({"payUrl": response_data["payUrl"], "orderId": order_id})
        else:
            return jsonify({"success": False, "error": response_data.get("message", "Error from MoMo")}), 400
            
    except Exception as e:
        logging.error(f"Error creating MoMo payment: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@payment_bp.route('/payment-callback', methods=['POST'])
def payment_callback():
    try:
        db = firestore.client()
        data = request.get_json()
        logging.info(f"MoMo Callback: {data}")
        
        # resultCode 0 là thành công
        if data.get("resultCode") == 0:
            user_id = data.get("extraData")
            if user_id:
                db.collection("users").document(user_id).set({
                    "isPremium": True,
                    "subscriptionStatus": "active",
                    "premiumSince": firestore.SERVER_TIMESTAMP
                }, merge=True)
                logging.info(f"User {user_id} upgraded to Premium")
        return jsonify({"status": "ok"})
    except Exception as e:
        logging.error(f"Error processing callback: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500
