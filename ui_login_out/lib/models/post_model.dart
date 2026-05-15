import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  final String content;
  final String tag;
  final String authorName;
  final String authorBio;
  final DateTime createdAt;
  final int interactionCount;

  PostModel({
    this.id,
    required this.content,
    required this.tag,
    required this.authorName,
    required this.authorBio,
    required this.createdAt,
    this.interactionCount = 0,
  });

  // Chuyển sang Map để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'tag': tag,
      'authorName': authorName,
      'authorBio': authorBio,
      'createdAt': createdAt, // Firebase sẽ tự hiểu là Timestamp
      'interactionCount': interactionCount,
    };
  }

  // Nhận dữ liệu từ Firebase về Object
  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      id: documentId,
      content: map['content'] ?? '',
      tag: map['tag'] ?? '',
      authorName: map['authorName'] ?? '',
      authorBio: map['authorBio'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      interactionCount: map['interactionCount'] ?? 0,
    );
  }
}