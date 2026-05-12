# 1. Sử dụng Python bản nhẹ (slim) để giảm dung lượng image
FROM python:3.9-slim

# 2. Thiết lập thư mục làm việc trong container
WORKDIR /app

# 3. Copy file requirements vào trước để tận dụng cache của Docker
COPY requirements.txt .

# 4. Cài đặt các thư viện cần thiết
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy toàn bộ code và file model (.pkl, .csv) vào container
COPY . .

# 6. Mở cổng 8080 (cổng mặc định của Cloud Run và Flask chúng ta đã cấu hình)
EXPOSE 8080

# 7. Chạy server bằng Gunicorn (chuyên nghiệp hơn dùng app.run của Flask)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]