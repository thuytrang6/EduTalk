import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  static const String _baseUrl = "https://edutalk-7ndf.onrender.com";

  Future<MomoPaymentResponse> createMomoPayment({
    required String userId,
    required int amount,
    required String orderInfo,
    required String planName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/payment/momo-payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "orderInfo": orderInfo,
          "userId": userId,
          "plan": planName,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return MomoPaymentResponse.fromJson(data);
      } else {
        throw Exception("Failed to create payment: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  Future<void> openMomoPayment(String payUrl, {String? deeplink}) async {
    // 1. Ưu tiên mở bằng Deep Link (momo://) nếu có
    if (deeplink != null && deeplink.isNotEmpty) {
      try {
        final Uri deepUri = Uri.parse(deeplink);
        bool launched = await launchUrl(
          deepUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (launched) return;
      } catch (e) {
        debugPrint("Lỗi khi mở deeplink: $e");
      }
    }

    // 2. Fallback: Mở bằng payUrl (https://)
    final Uri webUri = Uri.parse(payUrl);
    try {
      // Thử mở HTTPS link bằng App trước (Universal Link)
      bool launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) return;
    } catch (e) {
      // Bắt lỗi nếu không tìm thấy App phù hợp
    }

    // 3. Cuối cùng: Mở bằng trình duyệt
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Could not launch $payUrl");
    }
  }

  Future<Map<String, dynamic>> createBankPayment({
    required String userId,
    required int amount,
    required String planName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/payment/create-bank-payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "userId": userId,
          "plan": planName,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Failed to create bank payment: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  Stream<bool> listenPremiumStatus(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data() as Map<String, dynamic>?;
          return data?['isPremium'] ?? false;
        });
  }

  Future<Map<String, dynamic>?> checkPremiumStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/payment/check-status/$userId"),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Lỗi kiểm tra trạng thái Premium: $e");
    }
    return null;
  }
}
