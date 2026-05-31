import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, admin }
enum SubscriptionPlan { monthly, yearly, lifetime, none }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final bool isPremium;
  final int usageCount;
  final int freeLimit;
  final SubscriptionPlan plan; // Enum
  final DateTime? premiumStart;
  final DateTime? premiumExpiry;
  final DateTime? premiumAt; // Thời điểm thanh toán thành công gần nhất
  final String subscriptionStatus; // active, expired, cancelled, none
  final String? premiumSince;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = UserRole.user,
    required this.createdAt,
    this.isPremium = false,
    this.usageCount = 0,
    this.freeLimit = 3,
    this.plan = SubscriptionPlan.none,
    this.premiumStart,
    this.premiumExpiry,
    this.premiumAt,
    this.subscriptionStatus = 'none',
    this.premiumSince,
  });

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (plan == SubscriptionPlan.lifetime) return true;
    if (premiumExpiry == null) return false;
    return premiumExpiry!.isAfter(DateTime.now());
  }

  String get currentPlanName {
    switch (plan) {
      case SubscriptionPlan.monthly:
        return 'Gói Tháng';
      case SubscriptionPlan.yearly:
        return 'Gói Năm';
      case SubscriptionPlan.lifetime:
        return 'Gói Trọn Đời';
      default:
        return 'Free';
    }
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] ?? false,
      usageCount: data['usageCount'] ?? 0,
      freeLimit: data['freeLimit'] ?? 3,
      plan: _parsePlan(data['plan']),
      premiumStart: (data['premiumStart'] as Timestamp?)?.toDate(),
      premiumExpiry: (data['premiumExpiry'] as Timestamp?)?.toDate(),
      premiumAt: (data['premiumAt'] as Timestamp?)?.toDate(),
      subscriptionStatus: data['subscriptionStatus'] ?? 'none',
      premiumSince: data['premiumSince'],
    );
  }

  static SubscriptionPlan _parsePlan(String? plan) {
    switch (plan) {
      case 'monthly': return SubscriptionPlan.monthly;
      case 'yearly': return SubscriptionPlan.yearly;
      case 'lifetime': return SubscriptionPlan.lifetime;
      default: return SubscriptionPlan.none;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'created_at': Timestamp.fromDate(createdAt),
      'isPremium': isPremium,
      'usageCount': usageCount,
      'freeLimit': freeLimit,
      'plan': plan == SubscriptionPlan.none ? null : plan.name,
      'premiumStart': premiumStart != null ? Timestamp.fromDate(premiumStart!) : null,
      'premiumExpiry': premiumExpiry != null ? Timestamp.fromDate(premiumExpiry!) : null,
      'subscriptionStatus': subscriptionStatus,
      'premiumSince': premiumSince,
    };
  }
}
