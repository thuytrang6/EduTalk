import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/payment_service.dart';

class BankTransferSheet extends StatefulWidget {
  final String planName;
  final String userId;
  final int price;

  const BankTransferSheet({
    Key? key,
    required this.planName,
    required this.userId,
    required this.price,
  }) : super(key: key);

  @override
  State<BankTransferSheet> createState() => _BankTransferSheetState();
}

class _BankTransferSheetState extends State<BankTransferSheet> {
  String? paymentCode;
  bool isLoading = true;
  StreamSubscription? _subscription;

  // Cấu hình ngân hàng OCB của bạn
  final String bankId = "OCB";
  final String accountNo = "SEPEDUTALKVN26";
  final String accountName = "NGUYEN ANH QUAN";

  @override
  void initState() {
    super.initState();
    _initPayment();
    _listenToPremiumStatus();
  }

  Future<void> _initPayment() async {
    try {
      final res = await PaymentService().createBankPayment(
        userId: widget.userId,
        amount: widget.price,
        planName: widget.planName,
      );
      if (mounted) {
        setState(() {
          paymentCode = res['paymentCode'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khởi tạo thanh toán: $e")),
        );
        Navigator.pop(context);
      }
    }
  }

  void _listenToPremiumStatus() {
    _subscription = PaymentService().listenPremiumStatus(widget.userId).listen((isPremium) {
      if (isPremium && mounted) {
        _subscription?.cancel();
        Navigator.pop(context); // Đóng sheet thanh toán
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text("Thanh toán thành công!", textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          "Tài khoản của bạn đã được nâng cấp lên Premium. Hãy tận hưởng các tính năng mới nhé!",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Tuyệt vời", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã sao chép vào bộ nhớ tạm!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final String qrUrl = "https://img.vietqr.io/image/$bankId-$accountNo-qr_only.png?amount=${widget.price}&addInfo=$paymentCode&accountName=$accountName";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Quét mã để thanh toán",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              "Hệ thống sẽ tự động kích hoạt sau khi nhận được tiền",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            // VietQR Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      qrUrl,
                      width: 220,
                      height: 220,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, size: 18, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text(
                        "VietQR - Quét bằng mọi app Bank",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Table
            _buildInfoCard(),
            
            const SizedBox(height: 24),
            
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Đang chờ hệ thống xác nhận thanh toán...",
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Đóng",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _infoItem("Ngân hàng", "OCB - Ngân hàng Phương Đông"),
          const Divider(height: 20),
          _infoItem("Số tài khoản", accountNo, canCopy: true),
          const Divider(height: 20),
          _infoItem("Chủ tài khoản", accountName),
          const Divider(height: 20),
          _infoItem("Số tiền", "${widget.price}đ", isRed: true),
          const Divider(height: 20),
          _infoItem("Nội dung chuyển khoản", paymentCode ?? "", canCopy: true, isBold: true),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, {bool canCopy = false, bool isRed = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                    color: isRed ? Colors.red : const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (canCopy)
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF2563EB)),
                  onPressed: () => _copyToClipboard(value),
                  padding: const EdgeInsets.only(left: 8),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
