import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; 

  // 1. Hàm Upload ảnh lên Firebase Storage
  Future<String?> uploadPostImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('post_images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); 
    } catch (e) {
      debugPrint("Lỗi Upload Ảnh: $e");
      return null;
    }
  }

  // 2. Hàm đẩy bài viết lên Cloud
  Future<void> createPost(PostModel post) async {
    try {
      await _db.collection('posts').add(post.toMap());
    } catch (e) {
      debugPrint("Lỗi PostService (createPost): $e");
      rethrow; 
    }
  }

  // 3. Hàm lấy bài viết chung 
  Stream<List<PostModel>> getPostsStream() {
    return _db
        .collection('posts')
        .where('isPending', isEqualTo: false) 
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 4. Hàm lấy bài viết của chính mình
  Stream<List<PostModel>> getMyPostsStream(String uid) {
    return _db
        .collection('posts')
        .where('authorId', isEqualTo: uid) 
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 5. Hàm Gắn cờ (Report) - CÓ CHECK TRÙNG UID
  Future<String> reportPost(String postId, String uid) async {
    DocumentReference postRef = _db.collection('posts').doc(postId);
    String result = "success";

    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      List<dynamic> reportedBy = snapshot.get('reportedBy') ?? [];
      if (reportedBy.contains(uid)) {
        result = "already_reported"; 
        return; 
      }

      int currentReports = snapshot.get('reportCount') ?? 0;
      int newReportCount = currentReports + 1;

      transaction.update(postRef, {
        'reportedBy': FieldValue.arrayUnion([uid]),
        'reportCount': newReportCount,
        'isPending': newReportCount >= 5,
      });

      DocumentReference notifRef = _db.collection('admin_notifications').doc();
      transaction.set(notifRef, {
        'type': 'post_report',
        'postId': postId,
        'reportCount': newReportCount,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'unread',
        'message': 'Một bài viết trong cộng đồng vừa bị báo cáo!',
      });
    });
    return result;
  }

  // 6. Hàm Tương tác (Upvote) - Hoạt động như công tắc (Toggle)
  Future<void> upvotePost(String postId, String uid) async {
    DocumentReference postRef = _db.collection('posts').doc(postId);

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      List<dynamic> upvotedBy = snapshot.get('upvotedBy') ?? [];
      int currentCount = snapshot.get('interactionCount') ?? 0;

      if (upvotedBy.contains(uid)) {
        // HỦY VOTE
        transaction.update(postRef, {
          'upvotedBy': FieldValue.arrayRemove([uid]),
          'interactionCount': currentCount - 1
        });
      } else {
        // VOTE
        transaction.update(postRef, {
          'upvotedBy': FieldValue.arrayUnion([uid]),
          'interactionCount': currentCount + 1
        });
      }
    });
  }

  // 7. Hàm Xóa bài viết 
  Future<void> deletePost(String postId) async {
    try {
      await _db.collection('posts').doc(postId).delete();
    } catch (e) {
      debugPrint("Lỗi Xóa bài: $e");
      rethrow;
    }
  }
  // 8. Hàm Sửa bài viết
  Future<void> editPost(String postId, String newContent) async {
    try {
      await _db.collection('posts').doc(postId).update({
        'content': newContent,
      });
    } catch (e) {
      debugPrint("Lỗi Sửa bài: $e");
      rethrow;
    }
  }
  // 9. Hàm Thêm bình luận (Comment)
  Future<void> addComment(String postId, CommentModel comment) async {
    DocumentReference postRef = _db.collection('posts').doc(postId);
    DocumentReference newCommentRef = postRef.collection('comments').doc();

    try {
      await _db.runTransaction((transaction) async {
        // 1. Lưu bình luận
        transaction.set(newCommentRef, comment.toMap());
        
        // 2. Tăng 2 điểm interaction và 1 điểm commentCount cho bài viết
        transaction.update(postRef, {
          'interactionCount': FieldValue.increment(2),
          'commentCount': FieldValue.increment(1),
        });
      });

      // 3. Gửi thông báo cho chủ bài viết (nằm trong try để bắt lỗi)
      final postDoc = await _db.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        final String authorId = postDoc['authorId'];
        await sendNotification(receiverId: authorId, type: 'comment', postId: postId);
      }
    } catch (e) {
      debugPrint("Lỗi thêm bình luận: $e");
      rethrow;
    }
  }
  // 10. Hàm lấy danh sách bình luận (Real-time)
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true) // Mới nhất xếp trên
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
  // 11. Hàm Tương tác (Upvote) cho bình luận
  Future<void> upvoteComment(String postId, String commentId, String uid) async {
    DocumentReference commentRef = _db.collection('posts').doc(postId).collection('comments').doc(commentId);

    bool isLiking = false; 
    String? commentAuthorId; 
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(commentRef);
      if (!snapshot.exists) return;

      List<dynamic> upvotedBy = snapshot.get('upvotedBy') ?? [];
      int currentCount = snapshot.get('interactionCount') ?? 0;
      commentAuthorId = snapshot.get('authorId'); // Lấy ID của người viết bình luận này

      if (upvotedBy.contains(uid)) {
        // Trường hợp Bỏ tim (Unlike)
        transaction.update(commentRef, {
          'upvotedBy': FieldValue.arrayRemove([uid]),
          'interactionCount': currentCount - 1
        });
        isLiking = false; // Đánh dấu là đang bỏ tim
      } else {
        // Trường hợp Thả tim (Like)
        transaction.update(commentRef, {
          'upvotedBy': FieldValue.arrayUnion([uid]),
          'interactionCount': currentCount + 1
        });
        isLiking = true; // Đánh dấu là đang thả tim
      }
    });

    // CHỈ GỬI THÔNG BÁO KHI: 
    // 1. Hành động là Thả tim (không phải bỏ tim)
    // 2. Tìm thấy ID của chủ bình luận
    if (isLiking && commentAuthorId != null) {
      await sendNotification(
        receiverId: commentAuthorId!, 
        type: 'like', // Đổi thành 'like' vì đây là thả tim
        postId: postId
      );
    }
  }
  // 12. Lấy danh sách thông báo của User hiện tại
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _db
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 13. Bắn thông báo lên Firebase
  Future<void> sendNotification({
    required String receiverId,
    required String type,
    required String postId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    // Bỏ qua nếu chưa đăng nhập hoặc tự like/comment bài của chính mình
    if (currentUser == null || currentUser.uid == receiverId) return;

    final userDoc = await _db.collection('users').doc(currentUser.uid).get();
    String senderName = userDoc.data()?['name'] ?? "Thành viên EduTalk";

    await _db.collection('notifications').add({
      'receiverId': receiverId,
      'senderId': currentUser.uid,
      'senderName': senderName,
      'type': type,
      'postId': postId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 14. Đánh dấu một thông báo là đã đọc
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint("Lỗi markNotificationAsRead: $e");
    }
  }

  // 15. Đánh dấu tất cả thông báo là đã đọc (batch write)
  Future<void> markAllNotificationsAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    try {
      final batch = _db.batch();
      for (final id in notificationIds) {
        batch.update(_db.collection('notifications').doc(id), {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Lỗi markAllNotificationsAsRead: $e");
    }
  }
}