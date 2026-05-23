import 'dart:convert';
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/create-momo-payment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "orderInfo": orderInfo,
          "userId": userId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return MomoPaymentResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create payment: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  Future<void> openMomoPayment(String payUrl) async {
    final Uri uri = Uri.parse(payUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Could not launch $payUrl");
    }
  }

  Future<void> submitBankTransfer({
    required String userId,
    required int amount,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'pendingPayment': {
        'method': 'bank_transfer',
        'amount': amount,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      }
    });
  }

  Stream<bool> listenPremiumStatus(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['isPremium'] ?? false);
  }
}
