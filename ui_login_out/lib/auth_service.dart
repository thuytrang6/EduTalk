import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Khai báo instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.updateDisplayName(name);
      String uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'user', 
        'created_at': FieldValue.serverTimestamp(),
      });

      return {"status": "success"};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {"status": "Mật khẩu quá yếu."};
      } else if (e.code == 'email-already-in-use') {
        return {"status": "Email này đã được đăng ký."};
      }
      return {"status": e.message ?? "Lỗi đăng ký"};
    } catch (e) {
      return {"status": "Lỗi hệ thống: $e"};
    }
  }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role') ?? 'user';
        return {
          "status": "success",
          "role": role,
        }; 
      } else {
        return {"status": "Không tìm thấy dữ liệu người dùng."};
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return {"status": "Sai email hoặc mật khẩu."};
      }
      return {"status": e.message ?? "Lỗi đăng nhập"};
    } catch (e) {
      return {"status": "Lỗi hệ thống: $e"};
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
