import joblib
import pandas as pd
import logging
from flask import Blueprint, request, jsonify
from firebase_admin import firestore

# Khởi tạo Blueprint cho Prediction
prediction_bp = Blueprint('prediction', __name__)

# ── LOAD MODEL VÀ DATA ─────────────────────────────────────────────────────────
# Lưu ý: Trong thực tế nên dùng singleton hoặc load 1 lần ở main rồi pass qua
# Nhưng để đơn giản và đúng cấu trúc Blueprint, ta load tại đây hoặc dùng current_app
model = joblib.load('rf_model.pkl')
uni_df = pd.read_csv('UniversityData_Full.csv')

FEATURE_NAMES = [
    "Năng động", "Hướng nội", "Sáng tạo", "Logic", "Tò mò",
    "Cảm thông", "Yêu Công nghệ", "Yêu Xã hội", "Yêu Sức khỏe", "Yêu Nghệ thuật"
]

@prediction_bp.route('/predict', methods=['POST'])
def predict():
    try:
        db = firestore.client()
        data = request.get_json()
        user_scores = data.get('scores')
        user_id = data.get('userId') 

        if not user_scores or len(user_scores) != 10:
            return jsonify({"success": False, "error": "Thiếu dữ liệu 10 chỉ số"}), 400

        # Dự đoán
        input_df = pd.DataFrame([user_scores], columns=FEATURE_NAMES)
        prediction = model.predict(input_df)[0]

        # Gợi ý trường
        top_unis = uni_df[uni_df['nhom_nganh'] == prediction].head(5)
        unis_list = top_unis[['ten_truong', 'ten_nganh', 'diem_chuan_2024', 'website']].to_dict(orient='records')

        # Lưu vào Firestore (nếu có user_id)
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
        logging.error(f"Error during prediction: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@prediction_bp.route('/history/<user_id>', methods=['GET'])
def get_history(user_id):
    try:
        db = firestore.client()
        docs = db.collection('predictions') \
            .where('user_id', '==', user_id) \
            .order_by('timestamp', direction=firestore.Query.DESCENDING) \
            .limit(10) \
            .stream()

        history = []
        for doc in docs:
            d = doc.to_dict()
            d['id'] = doc.id
            if 'timestamp' in d and d['timestamp']:
                d['timestamp'] = d['timestamp'].isoformat()
            history.append(d)

        return jsonify({"success": True, "history": history})

    except Exception as e:
        logging.error(f"Error fetching history: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500
