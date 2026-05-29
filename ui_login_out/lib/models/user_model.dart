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
  final String? currentPlan;   // Tên hiển thị (ví dụ: 'Gói Tháng')
  final DateTime? premiumStart;
  final DateTime? premiumExpiry;
  final String subscriptionStatus; // active, expired, cancelled, none

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
    this.currentPlan,
    this.premiumStart,
    this.premiumExpiry,
    this.subscriptionStatus = 'none',
  });

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (plan == SubscriptionPlan.lifetime) return true;
    if (premiumExpiry == null) return false;
    return premiumExpiry!.isAfter(DateTime.now());
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
      currentPlan: data['currentPlan'],
      premiumStart: (data['premiumStart'] as Timestamp?)?.toDate(),
      premiumExpiry: (data['premiumExpiry'] as Timestamp?)?.toDate(),
      subscriptionStatus: data['subscriptionStatus'] ?? 'none',
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
      'currentPlan': currentPlan,
      'premiumStart': premiumStart != null ? Timestamp.fromDate(premiumStart!) : null,
      'premiumExpiry': premiumExpiry != null ? Timestamp.fromDate(premiumExpiry!) : null,
      'subscriptionStatus': subscriptionStatus,
    };
  }
}
