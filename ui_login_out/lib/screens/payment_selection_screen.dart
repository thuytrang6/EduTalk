import 'package:flutter/material.dart';
import '../widgets/bank_transfer_sheet.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final String planName;
  final String userId;
  final double planPrice;

  const PaymentSelectionScreen({
    Key? key,
    required this.planName,
    required this.userId,
    required this.planPrice,
  }) : super(key: key);

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  PaymentMethod? _selectedMethod;
  bool _isLoading = false;

  void _onConfirm() async {
    if (_selectedMethod == null) return;

    if (_selectedMethod == PaymentMethod.momo) {
      setState(() => _isLoading = true);
      try {
        final res = await PaymentService().createMomoPayment(
          userId: widget.userId,
          amount: widget.planPrice.toInt(),
          orderInfo: "EduTalk Premium ${widget.planName}",
          planName: widget.planName,
        );
        if (res.payUrl != null) {
          await PaymentService().openMomoPayment(res.payUrl!, deeplink: res.deeplink);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
        if (mounted) Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => BankTransferSheet(
          planName: widget.planName,
          userId: widget.userId,
          price: widget.planPrice.toInt(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Chọn phương thức", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          Text("${widget.planName} - ${widget.planPrice.toInt()}đ", style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          _buildOption(PaymentMethod.momo, "Ví MoMo", "Thanh toán qua ví MoMo hoặc quét QR", Icons.wallet, const Color(0xFFAE2070), true),
          const SizedBox(height: 12),
          _buildOption(PaymentMethod.bankTransfer, "Chuyển khoản", "Chuyển khoản và gửi ảnh xác nhận", Icons.account_balance, const Color(0xFF2563EB), false),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedMethod == null || _isLoading ? null : _onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Tiếp tục thanh toán", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(PaymentMethod method, String title, String sub, IconData icon, Color color, bool isRecommended) {
    bool isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (isRecommended) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)), child: const Text("Khuyến nghị", style: TextStyle(color: Colors.green, fontSize: 10)))]
                ]),
                Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
