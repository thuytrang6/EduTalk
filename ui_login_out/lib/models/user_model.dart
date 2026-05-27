import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final Timestamp createdAt;
  final bool isPremium;
  final int usageCount;
  final String? currentPlan; // 'Gói Tháng', 'Gói Năm', 'Gói Trọn Đời'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isPremium = false,
    this.usageCount = 0,
    this.currentPlan,
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
      currentPlan: data['currentPlan'],
    );
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
      'currentPlan': currentPlan,
    };
  }
}