import hmac
import hashlib
import uuid
import json
import requests
import logging
from fastapi import APIRouter, Request, HTTPException
from firebase_admin import firestore
from datetime import datetime

router = APIRouter()
db = firestore.client()

# MoMo Configuration
CONFIG = {
    "partnerCode": "MOMOBKUN20180529",
    "accessKey": "klm05TvNBzhg7h7j",
    "secretKey": "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa",
    "endpoint": "https://test-payment.momo.vn/v2/gateway/api/create",
    "redirectUrl": "edutalk://payment-result",
    "ipnUrl": "https://edutalk-7ndf.onrender.com/payment-callback",
    "requestType": "captureWallet"
}

def create_signature(data):
    raw_signature = f"accessKey={CONFIG['accessKey']}&amount={data['amount']}&extraData={data['extraData']}&ipnUrl={CONFIG['ipnUrl']}&orderId={data['orderId']}&orderInfo={data['orderInfo']}&partnerCode={CONFIG['partnerCode']}&redirectUrl={CONFIG['redirectUrl']}&requestId={data['requestId']}&requestType={CONFIG['requestType']}"
    h = hmac.new(CONFIG['secretKey'].encode('utf-8'), raw_signature.encode('utf-8'), digestmod=hashlib.sha256)
    return h.hexdigest()

@router.post("/create-momo-payment")
async def create_momo_payment(request: Request):
    try:
        body = await request.json()
        amount = body.get("amount")
        order_info = body.get("orderInfo")
        user_id = body.get("userId")
        
        order_id = str(uuid.uuid4())
        request_id = str(uuid.uuid4())
        
        payload = {
            "partnerCode": CONFIG["partnerCode"],
            "accessKey": CONFIG["accessKey"],
            "requestId": request_id,
            "amount": str(amount),
            "orderId": order_id,
            "orderInfo": order_info,
            "redirectUrl": CONFIG["redirectUrl"],
            "ipnUrl": CONFIG["ipnUrl"],
            "requestType": CONFIG["requestType"],
            "extraData": user_id,
            "lang": "vi"
        }
        
        payload["signature"] = create_signature({**payload, "orderId": order_id, "requestId": request_id})
        
        response = requests.post(CONFIG["endpoint"], json=payload)
        response_data = response.json()
        
        if response.status_code == 200 and response_data.get("resultCode") == 0:
            return {"payUrl": response_data["payUrl"], "orderId": order_id}
        else:
            raise HTTPException(status_code=400, detail=response_data.get("message", "Error from MoMo"))
            
    except Exception as e:
        logging.error(f"Error creating MoMo payment: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/payment-callback")
async def payment_callback(request: Request):
    try:
        data = await request.json()
        logging.info(f"MoMo Callback: {data}")
        
        if data.get("resultCode") == 0:
            user_id = data.get("extraData")
            if user_id:
                db.collection("users").document(user_id).set({
                    "isPremium": True,
                    "subscriptionStatus": "active",
                    "premiumSince": firestore.SERVER_TIMESTAMP
                }, merge=True)
        return {"status": "ok"}
    except Exception as e:
        logging.error(f"Error processing callback: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
