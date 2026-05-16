import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentService {
  static const String baseUrl = 'https://edutalk-7ndf.onrender.com';

  // ── Map plan code từ tên hiển thị ─────────────────────────────────────────
  // Premium_screen gửi title ("Gói Tháng") → convert sang plan code ("monthly")
  static const Map<String, String> _planCodeMap = {
    'Gói Tháng':    'monthly',
    'Gói Năm':      'yearly',
    'Gói Trọn Đời': 'lifetime',
  };

  static String _toPlanCode(String planName) {
    return _planCodeMap[planName] ?? 'monthly';
  }

  // ── GỌI API TẠO ĐƠN MOMO ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> _createOrder({
    required String userId,
    required String plan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/momo-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'plan':    plan,   // gửi plan code: 'monthly' | 'yearly' | 'lifetime'
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  }

  // ── XỬ LÝ THANH TOÁN CHÍNH ───────────────────────────────────────────────
  // planName: tên hiển thị từ UI ("Gói Tháng" | "Gói Năm" | "Gói Trọn Đời")
  Future<void> handlePayment(
      BuildContext context, {
        required double amount,   // giữ lại để tương thích, backend tự lấy amount từ plan
        required String userId,
        required String plan,     // nhận planName từ Premium_screen
      }) async {
    final planCode = _toPlanCode(plan); // convert "Gói Tháng" → "monthly"

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _createOrder(userId: userId, plan: planCode);

      if (context.mounted) Navigator.pop(context);

      if (result['success'] == true) {
        final deeplink = result['deeplink'] as String?;
        final payUrl   = result['payUrl']   as String?;
        final orderId  = result['orderId']  as String? ?? '';

        // Ưu tiên 1: Mở app MoMo UAT qua deeplink
        if (deeplink != null && deeplink.isNotEmpty) {
          final uri = Uri.parse(deeplink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        }

        // Ưu tiên 2: Fallback WebView
        if (payUrl != null && payUrl.isNotEmpty && context.mounted) {
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
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lỗi: ${result['message'] ?? 'Không thể tạo đơn hàng'}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi kết nối: $e"),
            backgroundColor: Colors.redAccent,
          ),
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
          // Bắt deeplink MoMo trong WebView
          if (req.url.startsWith('momo://') || req.url.startsWith('momo-uat://')) {
            launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          // Bắt redirect sau thanh toán
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
            title: const Text(" Thanh toán thành công!"),
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
          const SnackBar(
            content: Text("Thanh toán thất bại hoặc bị huỷ"),
            backgroundColor: Colors.redAccent,
          ),
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