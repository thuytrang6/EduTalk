import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final Timestamp createdAt;
  final bool isPremium;
  final int usageCount;
  final int freeLimit;
  final String? plan;         // 'monthly' | 'yearly' | 'lifetime'
  final String? currentPlan;  // 'Gói Tháng', 'Gói Năm', 'Gói Trọn Đời'
  final Timestamp? premiumStart;
  final Timestamp? premiumExpiry;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isPremium = false,
    this.usageCount = 0,
    this.freeLimit = 3,
    this.plan,
    this.currentPlan,
    this.premiumStart,
    this.premiumExpiry,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['created_at'] ?? Timestamp.now(),
      isPremium: data['isPremium'] ?? false,
      usageCount: data['usageCount'] ?? 0,
      freeLimit: data['freeLimit'] ?? 3,
      plan: data['plan'],
      currentPlan: data['currentPlan'],
      premiumStart: data['premiumStart'],
      premiumExpiry: data['premiumExpiry'],
    );
  }

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (plan == 'lifetime') return true;
    if (premiumExpiry == null) return false;
    return premiumExpiry!.toDate().isAfter(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt,
      'isPremium': isPremium,
      'usageCount': usageCount,
      'freeLimit': freeLimit,
      'plan': plan,
      'currentPlan': currentPlan,
      'premiumStart': premiumStart,
      'premiumExpiry': premiumExpiry,
    };
  }
  }