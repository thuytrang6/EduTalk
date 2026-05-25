import hmac
import hashlib
import uuid
import requests
import logging
import json
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
    "ipnUrl": "https://edutalk-7ndf.onrender.com/payment-callback",
    "requestType": "captureWallet"
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
    # Các trường để tạo chữ ký callback MoMo (IPN)
    # Thứ tự: accessKey, amount, extraData, message, orderId, orderInfo, orderType, partnerCode, payType, requestId, responseTime, resultCode, transId
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

@payment_bp.route('/momo-payment', methods=['POST'])
def create_momo_payment():
    try:
        data = request.get_json()
        amount = data.get("amount")
        order_info = data.get("orderInfo")
        user_id = data.get("userId")
        plan = data.get("plan") # Lấy plan từ frontend

        order_id = str(uuid.uuid4())
        request_id = str(uuid.uuid4())
        
        # Đóng gói extraData thành JSON string
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
        
        # 1. Xác thực chữ ký từ MoMo
        if not verify_momo_signature(data):
            logging.error("Invalid MoMo signature!")
            return jsonify({"status": "error", "message": "Invalid signature"}), 400

        # 2. Kiểm tra resultCode (0 là thành công)
        if str(data.get("resultCode")) == "0":
            extra_data_str = data.get("extraData")
            if extra_data_str:
                # Parse JSON từ extraData
                extra_data = json.loads(extra_data_str)
                user_id = extra_data.get("user_id")
                plan = extra_data.get("plan")
                
                if user_id:
                    db = firestore.client()
                    
                    # Cập nhật thông tin Premium cho User
                    db.collection("users").document(user_id).set({
                        "isPremium": True,
                        "subscriptionStatus": "active",
                        "currentPlan": plan,
                        "premiumSince": firestore.SERVER_TIMESTAMP
                    }, merge=True)
                    
                    # TẠO GIAO DỊCH TRONG FIREBASE (Transactions)
                    db.collection("transactions").add({
                        "userId": user_id,
                        "amount": data.get("amount"),
                        "plan": plan,
                        "status": "success",
                        "transId": data.get("transId"),
                        "orderId": data.get("orderId"),
                        "message": data.get("message"),
                        "method": "momo",
                        "timestamp": firestore.SERVER_TIMESTAMP
                    })
                    
                    logging.info(f"Successfully upgraded user {user_id} and recorded transaction")
        else:
            logging.warning(f"Payment failed with resultCode: {data.get('resultCode')}")
        
        # Phản hồi lại cho MoMo để xác nhận đã nhận IPN
        return jsonify({"status": "ok"}), 200
        
    except Exception as e:
        logging.error(f"Error processing MoMo callback: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500
