# EduTalk - Tài liệu Tích hợp Thanh toán

Tài liệu này mô tả cơ sở hạ tầng thanh toán cho dự án EduTalk, sử dụng MoMo làm cổng thanh toán chính.

## Cấu hình MoMo
Các thông tin xác thực và thiết lập sau đây được sử dụng cho việc tích hợp MoMo:

- **Partner Code**: `MOMOBKUN20180529`
- **Access Key**: `klm05TvNBzhg7h7j`
- **Secret Key**: `at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa`
- **Request Type**: `captureWallet`
- **Partner Name**: `EduTalk`

## Các API Endpoints
- **Test Endpoint (Tạo thanh toán)**: `https://test-payment.momo.vn/v2/gateway/api/create`
- **Redirect URL (App)**: `edutalk://payment-result`
- **IPN URL (Callback)**: `https://edutalk-7ndf.onrender.com/payment/payment-callback`

## Luồng Thanh toán (Payment Flow)
1. **Yêu cầu từ Frontend**: Ứng dụng Flutter (`PaymentSelectionScreen`) gọi `PaymentService` để bắt đầu giao dịch thông qua route `/momo-payment` của Backend.
2. **Tạo Giao dịch**: Backend (`payment_controller.py`) tạo `uuid` cho `orderId` và `requestId`, xây dựng payload đã ký sử dụng `HMAC-SHA256`, và yêu cầu URL thanh toán từ MoMo.
3. **Thanh toán**: Người dùng hoàn tất thanh toán bằng `payUrl` hoặc `deeplink` được cung cấp.
4. **Callback (IPN)**: Sau khi thanh toán xong, MoMo gửi thông báo bất đồng bộ đến route `/payment-callback`.
5. **Xác thực & Hoàn tất**: Backend xác thực chữ ký MoMo, xác nhận `resultCode == 0`, phân tích `extraData` (chứa `userId` và `plan`), sau đó cập nhật trạng thái của người dùng thành "Premium" trong Firestore và ghi lại giao dịch vào bộ sưu tập `transactions`.