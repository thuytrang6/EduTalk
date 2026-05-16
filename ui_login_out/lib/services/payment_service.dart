import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentService {
  static const String baseUrl = 'https://edutalk-7ndf.onrender.com';

  // ── GỌI API TẠO ĐƠN MOMO ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createMoMoPayment({
    required double amount,
    required String orderId,
    required String orderInfo,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/momo-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount':    amount.toInt().toString(),
          'user_id':   userId,
          'orderId':   orderId,
          'orderInfo': orderInfo,
          'requestId': orderId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi tạo thanh toán MoMo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối server: $e');
    }
  }

  // ── XỬ LÝ THANH TOÁN: deeplink → app MoMo UAT, fallback → WebView ──────────
  Future<void> handlePayment(
    BuildContext context, {
    required double amount,
    required String userId,
    required String plan,
  }) async {
    // Hiện loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final orderId   = 'EDUTALK_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final orderInfo = 'EduTalk Premium - $plan';

      final result = await createMoMoPayment(
        amount:    amount,
        orderId:   orderId,
        orderInfo: orderInfo,
        userId:    userId,
      );

      if (context.mounted) Navigator.pop(context); // Đóng loading

      if (result['success'] == true) {
        final deeplink = result['deeplink'] as String?;
        final payUrl   = result['payUrl']   as String?;

        // ✅ Ưu tiên 1: Mở thẳng app MoMo UAT qua deeplink
        if (deeplink != null && deeplink.isNotEmpty) {
          final uri = Uri.parse(deeplink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        }

        // ✅ Ưu tiên 2: Fallback mở WebView nếu chưa cài app MoMo
        if (payUrl != null && payUrl.isNotEmpty) {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MoMoWebViewScreen(
                  payUrl:  payUrl,
                  orderId: orderId,
                ),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${result['message']}")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối: $e")),
        );
      }
    }
  }
}

// ── WEBVIEW FALLBACK ──────────────────────────────────────────────────────────
class MoMoWebViewScreen extends StatefulWidget {
  final String payUrl;
  final String orderId;
  const MoMoWebViewScreen({super.key, required this.payUrl, required this.orderId});

  @override
  State<MoMoWebViewScreen> createState() => _MoMoWebViewScreenState();
}

class _MoMoWebViewScreenState extends State<MoMoWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          // Bắt deeplink MoMo UAT khi redirect trong WebView
          if (req.url.startsWith('momo://') || req.url.startsWith('momo-uat://')) {
            launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          // Bắt callback sau thanh toán
          if (req.url.contains('/payment-callback')) {
            _handleResult(req.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.payUrl));
  }

  void _handleResult(String url) {
    final resultCode = Uri.parse(url).queryParameters['resultCode'];
    if (mounted) Navigator.pop(context);

    if (resultCode == '0') {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("🎉 Thanh toán thành công!"),
            content: const Text("Tài khoản đã được nâng cấp Premium."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tuyệt vời!"),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanh toán thất bại hoặc bị huỷ")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán MoMo"),
        backgroundColor: const Color(0xFFAE2070),
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
