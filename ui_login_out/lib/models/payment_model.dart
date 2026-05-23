enum PaymentMethod { momo, bankTransfer }
enum PaymentStatus { pending, success, failed, cancelled }

class PlanInfo {
  final String code;         // monthly | yearly | lifetime
  final String name;         // Gói Tháng | Gói Năm | Gói Trọn Đời
  final int amount;          // 29000 | 216000 | 499000
  final int durationDays;    // 30 | 365 | -1

  const PlanInfo({
    required this.code,
    required this.name,
    required this.amount,
    required this.durationDays,
  });

  static const Map<String, PlanInfo> plans = {
    'monthly': PlanInfo(
      code:         'monthly',
      name:         'Gói Tháng',
      amount:       29000,
      durationDays: 30,
    ),
    'yearly': PlanInfo(
      code:         'yearly',
      name:         'Gói Năm',
      amount:       216000,
      durationDays: 365,
    ),
    'lifetime': PlanInfo(
      code:         'lifetime',
      name:         'Gói Trọn Đời',
      amount:       499000,
      durationDays: -1,
    ),
  };
}

class MomoPaymentResponse {
  final String? payUrl;
  final String? orderId;
  final String? message;
  final int? resultCode;

  MomoPaymentResponse({this.payUrl, this.orderId, this.message, this.resultCode});

  factory MomoPaymentResponse.fromJson(Map<String, dynamic> json) {
    return MomoPaymentResponse(
      payUrl: json['payUrl'],
      orderId: json['orderId'],
      message: json['message'],
      resultCode: json['resultCode'],
    );
  }
}

class PaymentResult {
  final bool success;
  final String? payUrl;
  final String? deeplink;
  final String? qrCodeUrl;
  final String? orderId;
  final String? plan;
  final int? amount;
  final String? message;

  PaymentResult({
    required this.success,
    this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
    this.orderId,
    this.plan,
    this.amount,
    this.message,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success:   json['success'] ?? false,
      payUrl:    json['payUrl'],
      deeplink:  json['deeplink'],
      qrCodeUrl: json['qrCodeUrl'],
      orderId:   json['orderId'],
      plan:      json['plan'],
      amount:    json['amount'],
      message:   json['message'] ?? json['error'],
    );
  }
}
