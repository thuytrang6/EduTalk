import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hàm đẩy bài viết lên Cloud
  Future<void> createPost(PostModel post) async {
    try {
      await _db.collection('posts').add(post.toMap());
    } catch (e) {
      print("Lỗi PostService (createPost): $e");
      rethrow; 
    }
  }

  // Hàm lấy bài viết (Để dành cho bước sau hiển thị danh sách)
  Stream<List<PostModel>> getPostsStream() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}