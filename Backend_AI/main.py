import joblib
import pandas as pd
import os
import json
import hashlib
import hmac
import requests
import uuid
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore

app = Flask(__name__)
CORS(app)

# ── KHỞI TẠO FIREBASE ──────────────────────────────────────────────────────────
# Render/Railway: set biến môi trường FIREBASE_KEY = nội dung file serviceAccountKey.json
# Local: để file serviceAccountKey.json cùng thư mục
firebase_key_env = os.environ.get('FIREBASE_KEY')
if firebase_key_env:
    # Production (Render/Railway): đọc từ environment variable
    cred = credentials.Certificate(json.loads(firebase_key_env))
else:
    # Local development: đọc từ file
    cred = credentials.Certificate('serviceAccountKey.json')

firebase_admin.initialize_app(cred)
db = firestore.client()

# ── LOAD MODEL VÀ DATA ─────────────────────────────────────────────────────────
model = joblib.load('rf_model.pkl')
uni_df = pd.read_csv('UniversityData_Full.csv')

# Thứ tự 10 chỉ số phải CHÍNH XÁC như lúc train trên Colab
FEATURE_NAMES = [
    "Năng động", "Hướng nội", "Sáng tạo", "Logic", "Tò mò",
    "Cảm thông", "Yêu Công nghệ", "Yêu Xã hội", "Yêu Sức khỏe", "Yêu Nghệ thuật"
]

# ── HEALTH CHECK ───────────────────────────────────────────────────────────────
@app.route('/', methods=['GET'], strict_slashes=False)
def health_check():
    return "AI Server is running!"

# ── API DỰ ĐOÁN NGÀNH + LƯU FIRESTORE ─────────────────────────────────────────
@app.route('/predict', methods=['POST'], strict_slashes=False)
def predict():
    try:
        data = request.get_json()
        user_scores = data.get('scores')
        user_id = data.get('user_id')  # Flutter gửi uid từ Firebase Auth

        if not user_scores or len(user_scores) != 10:
            return jsonify({"success": False, "error": "Thiếu dữ liệu 10 chỉ số"}), 400

        # Dự đoán
        input_df = pd.DataFrame([user_scores], columns=FEATURE_NAMES)
        prediction = model.predict(input_df)[0]

        # Gợi ý trường
        top_unis = uni_df[uni_df['nhom_nganh'] == prediction].head(5)
        unis_list = top_unis[['ten_truong', 'ten_nganh', 'diem_chuan_2024', 'website']].to_dict(orient='records')

        # 💾 Lưu vào Firestore (nếu có user_id)
        if user_id:
            db.collection('predictions').add({
                'user_id': user_id,
                'scores': user_scores,
                'predicted_major': prediction,
                'recommendations': unis_list,
                'timestamp': firestore.SERVER_TIMESTAMP
            })

        return jsonify({
            "success": True,
            "predicted_major": prediction,
            "recommendations": unis_list
        })

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ── API LẤY LỊCH SỬ DỰ ĐOÁN THEO USER ────────────────────────────────────────
@app.route('/history/<user_id>', methods=['GET'], strict_slashes=False)
def get_history(user_id):
    try:
        docs = db.collection('predictions') \
            .where('user_id', '==', user_id) \
            .order_by('timestamp', direction=firestore.Query.DESCENDING) \
            .limit(10) \
            .stream()

        history = []
        for doc in docs:
            d = doc.to_dict()
            d['id'] = doc.id
            # Convert timestamp để JSON serializable
            if 'timestamp' in d and d['timestamp']:
                d['timestamp'] = d['timestamp'].isoformat()
            history.append(d)

        return jsonify({"success": True, "history": history})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ── API ADMIN: ĐỘ QUAN TRỌNG CÁC YẾU TỐ ──────────────────────────────────────
@app.route('/admin/stats', methods=['GET'], strict_slashes=False)
def get_admin_stats():
    try:
        importances = model.feature_importances_
        feature_data = [
            {"feature": FEATURE_NAMES[i], "importance": round(float(v) * 100, 2)}
            for i, v in enumerate(importances)
        ]
        feature_data.sort(key=lambda x: x['importance'], reverse=True)

        # Thêm tổng số lượt dự đoán từ Firestore
        total_predictions = len(list(db.collection('predictions').stream()))

        return jsonify({
            "success": True,
            "total_predictions": total_predictions,
            "feature_importances": feature_data
        })

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ── MoMo PAYMENT INTEGRATION ─────────────────────────────────────────────────
# MoMo Sandbox Settings
MOMO_PARTNER_CODE = "MOMOBKUN20180529"
MOMO_ACCESS_KEY   = "klm05TvNBzhg7h7j"
MOMO_SECRET_KEY   = "at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa"
MOMO_ENDPOINT = "https://test-payment.momo.vn/v2/gateway/api/create"

@app.route('/momo-payment', methods=['POST', 'GET'], strict_slashes=False)
def create_momo_payment():
    if request.method == 'GET':
        return "Momo Payment endpoint is active. Use POST to create a payment link."
    try:
        data = request.get_json()
        if not data:
            return jsonify({"success": False, "message": "Missing JSON body"}), 400
            
        # Ép kiểu dữ liệu chuẩn
        # amount phải là chuỗi khi ký, nhưng là số khi gửi JSON
        raw_amount = str(data.get('amount', '0')).split('.')[0] 
        user_id = str(data.get('user_id', ''))
        order_id = str(data.get('orderId', uuid.uuid4()))
        order_info = str(data.get('orderInfo', "Thanh toan EduTalk"))
        request_id = str(data.get('requestId', order_id))
        extra_data = user_id if user_id else ""
        
        redirect_url = "https://edutalk-7ndf.onrender.com/payment-callback"
        ipn_url = "https://edutalk-7ndf.onrender.com/payment-callback"
        request_type = "captureWallet"

        # 1. Tạo chuỗi ký tự signature (Thứ tự Alphabet của key là BẮT BUỘC)
        raw_signature = (
            f"accessKey={MOMO_ACCESS_KEY}&"
            f"amount={raw_amount}&"
            f"extraData={extra_data}&"
            f"ipnUrl={ipn_url}&"
            f"orderId={order_id}&"
            f"orderInfo={order_info}&"
            f"partnerCode={MOMO_PARTNER_CODE}&"
            f"redirectUrl={redirect_url}&"
            f"requestId={request_id}&"
            f"requestType={request_type}"
        )

        # 2. Tạo chữ ký SHA256
        signature = hmac.new(
            MOMO_SECRET_KEY.encode('utf-8'),
            raw_signature.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()

        # 3. Payload gửi sang MoMo (amount phải là kiểu INT)
        payload = {
            "partnerCode": MOMO_PARTNER_CODE,
            "partnerName": "EduTalk",
            "storeId": MOMO_PARTNER_CODE, # Dùng luôn PartnerCode làm StoreId cho sandbox
            "requestId": request_id,
            "amount": int(raw_amount),
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
                "success": True,
                "payUrl": res_data.get('payUrl'),
                "message": "Tạo đơn hàng thành công"
            })
        else:
            return jsonify({
                "success": False,
                "message": res_data.get('message', "Lỗi từ MoMo"),
                "details": res_data
            }), 400

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/payment-callback', methods=['POST', 'GET'], strict_slashes=False)
def momo_callback():
    if request.method == 'GET':
        return "Momo Callback endpoint is active. Use POST to simulate a callback."
    try:
        data = request.get_json()
        print("MoMo Callback Data:", data) # Để debug trong console Render
        
        result_code = data.get('resultCode')
        user_id = data.get('extraData') # Lấy lại user_id đã gửi lúc đầu
        
        if result_code == 0 and user_id:
            # ✅ Thanh toán thành công -> Cập nhật Firestore
            user_ref = db.collection('users').document(user_id)
            user_ref.update({
                'isPremium': True,
                'premiumAt': firestore.SERVER_TIMESTAMP
            })
            return jsonify({"success": True, "message": "Updated Premium"}), 200
        
        return jsonify({"success": False, "message": "Payment failed or no user_id"}), 400
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)