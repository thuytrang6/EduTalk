import joblib
import pandas as pd
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# 1. LOAD MODEL VÀ DATA
# Đảm bảo các file này nằm cùng thư mục với main.py
model = joblib.load('rf_model.pkl')
uni_df = pd.read_csv('UniversityData_Full.csv')

# Thứ tự 10 chỉ số phải CHÍNH XÁC như lúc train trên Colab
FEATURE_NAMES = [
    "Năng động", "Hướng nội", "Sáng tạo", "Logic", "Tò mò", 
    "Cảm thông", "Yêu Công nghệ", "Yêu Xã hội", "Yêu Sức khỏe", "Yêu Nghệ thuật"
]

@app.route('/', methods=['GET'])
def health_check():
    return "AI Server is running!"

# API DÀNH CHO USER: Dự đoán ngành học
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        # Mobile gửi lên: {"scores": [5, 3, 4, ...]}
        user_scores = data.get('scores')
        
        if not user_scores or len(user_scores) != 10:
            return jsonify({"success": False, "error": "Thiếu dữ liệu 10 chỉ số"}), 400

        # Chuyển thành DataFrame
        input_df = pd.DataFrame([user_scores], columns=FEATURE_NAMES)
        
        # Thực hiện dự đoán
        prediction = model.predict(input_df)[0]
        
        # Gợi ý trường học (Lọc theo cột 'nhom_nganh' trong CSV)
        top_unis = uni_df[uni_df['nhom_nganh'] == prediction].head(5)
        unis_list = top_unis[['ten_truong', 'ten_nganh', 'diem_chuan_2024', 'website']].to_dict(orient='records')
        
        return jsonify({
            "success": True,
            "predicted_major": prediction,
            "recommendations": unis_list
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# API DÀNH CHO ADMIN: Xem độ quan trọng của các yếu tố
@app.route('/admin/stats', methods=['GET'])
def get_admin_stats():
    try:
        # Lấy độ quan trọng của các thuộc tính từ Random Forest
        importances = model.feature_importances_
        feature_data = []
        for i, val in enumerate(importances):
            feature_data.append({
                "feature": FEATURE_NAMES[i],
                "importance": round(float(val) * 100, 2)
            })
        
        # Sắp xếp từ cao xuống thấp
        feature_data.sort(key=lambda x: x['importance'], reverse=True)
        
        return jsonify({
            "success": True,
            "feature_importances": feature_data
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == '__main__':
    # Chạy trên port 8080 để phù hợp với Cloud Run
    app.run(host='0.0.0.0', port=8080)