import os
import json
import logging
from flask import Flask
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials

# Import Controllers
from Controllers.payment_controller import payment_bp
from Controllers.prediction_controller import prediction_bp

app = Flask(__name__)
CORS(app)

# ── KHỞI TẠO FIREBASE ──────────────────────────────────────────────────────────
firebase_key_env = os.environ.get('FIREBASE_KEY')
if firebase_key_env:
    cred = credentials.Certificate(json.loads(firebase_key_env))
else:
    cred = credentials.Certificate('serviceAccountKey.json')

if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

# ── ĐĂNG KÝ BLUEPRINTS ────────────────────────────────────────────────────────
app.register_blueprint(payment_bp, url_prefix='/api/payment')
app.register_blueprint(prediction_bp, url_prefix='/api/prediction')

@app.route('/', methods=['GET'])
def health_check():
    return "EduTalk AI Server is running!"

if __name__ == '__main__':
    # Cấu hình logging cơ bản
    logging.basicConfig(level=logging.INFO)
    app.run(host='0.0.0.0', port=8080)
