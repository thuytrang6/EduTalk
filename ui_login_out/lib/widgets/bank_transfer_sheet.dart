import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';

class BankTransferSheet extends StatelessWidget {
  final String planName;
  final String userId;
  final int price;

  const BankTransferSheet({Key? key, required this.planName, required this.userId, required this.price}) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép!")));
  }

  @override
  Widget build(BuildContext context) {
    final String content = "EduTalk ${planName.substring(0, 3)} ${userId.substring(userId.length - 6)}";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Thông tin chuyển khoản", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _infoRow("Ngân hàng", "MBBank"),
              _infoRow("STK", "0987654321", isCopyable: true, context: context),
              _infoRow("Chủ tài khoản", "NGUYEN VAN A"),
              _infoRow("Số tiền", "$price đ", textColor: Colors.red),
              _infoRow("Nội dung", content, isCopyable: true, context: context),
            ]),
          ),
          const SizedBox(height: 20),
          const Text("Sau khi chuyển khoản, admin sẽ kích hoạt Premium trong vòng 24h", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Huỷ"))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () {
              PaymentService().submitBankTransfer(userId: userId, amount: price);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cảm ơn! Chúng tôi sẽ xác nhận trong 24h")));
            }, child: const Text("Tôi đã chuyển khoản"))),
          ]),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isCopyable = false, Color? textColor, BuildContext? context}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Text(value, style: TextStyle(color: textColor))),
      if (isCopyable) IconButton(icon: const Icon(Icons.copy, size: 16), onPressed: () => _copyToClipboard(context!, value)),
    ]),
  );
}
