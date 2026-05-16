import joblib
import pandas as pd
import os
import json
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore
from controllers.payment_controller import payment_bp

app = Flask(__name__)
CORS(app)

# ── ĐĂNG KÝ BLUEPRINT ──────────────────────────────────────────────────────────
app.register_blueprint(payment_bp)

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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
