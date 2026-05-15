import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';

class ApiService {
  static const String baseUrl = 'https://edutalk-7ndf.onrender.com';

  Future<Map<String, dynamic>> predict({
    required List<double> scores,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'scores': scores, 'user_id': userId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi gọi API: ${response.statusCode}');
    }
  }

  //Payment
  Future<Map<String, dynamic>> createMoMoPayment({
    required double amount,
    required String orderId,
    required String orderInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/momo-payment'), // Endpoint này tạo ở Backend Render
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount.toString(),
          'orderId': orderId,
          'orderInfo': orderInfo,
          'requestId': orderId, // dùng chung với orderId(đon giản)
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

}
