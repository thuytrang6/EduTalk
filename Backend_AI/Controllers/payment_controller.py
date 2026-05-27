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
                    db.collection("users").document(user_id).set({
                        "isPremium": True,
                        "subscriptionStatus": "active",
                        "currentPlan": plan,
                        "premiumAt": firestore.SERVER_TIMESTAMP
                    }, merge=True)
                    
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
        amount_received = float(data.get("amount", 0))
        
        # 2. Phân tích nội dung để tìm paymentCode (Ví dụ: ET123456)
        if SEPAY_CONFIG['prefix'].upper() not in content.upper():
             return jsonify({"status": "ignored", "message": "Invalid prefix"}), 200
             
        # Tìm chính xác 6-8 chữ số trong nội dung chuyển khoản
        match = re.search(r'\d{6,8}', content)
        if not match:
            return jsonify({"status": "ignored", "message": "Payment code not found"}), 200
            
        payment_code = match.group(0)
        
        db = firestore.client()
        transaction_ref = db.collection("transactions").document(payment_code)
        transaction_doc = transaction_ref.get()
        
        if not transaction_doc.exists:
            return jsonify({"status": "error", "message": "Transaction not found"}), 404
            
        transaction_data = transaction_doc.to_dict()
        
        if transaction_data['status'] == 'success':
            return jsonify({"status": "ok", "message": "Already processed"}), 200
            
        if amount_received < transaction_data['amount']:
             return jsonify({"status": "error", "message": "Amount mismatch"}), 400
             
        user_id = transaction_data['userId']
        plan = transaction_data['plan']
        
        batch = db.batch()
        user_ref = db.collection("users").document(user_id)
        batch.set(user_ref, {
            "isPremium": True,
            "subscriptionStatus": "active",
            "currentPlan": plan,
            "premiumAt": firestore.SERVER_TIMESTAMP
        }, merge=True)
        
        batch.update(transaction_ref, {
            "status": "success",
            "timestamp": firestore.SERVER_TIMESTAMP,
            "sepayData": data
        })
        
        batch.commit()
        
        logging.info(f"Successfully upgraded user {user_id} via Bank Transfer (SePay)")
        return jsonify({"status": "ok"}), 200
        
    except Exception as e:
        logging.error(f"Error processing SePay webhook: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500
