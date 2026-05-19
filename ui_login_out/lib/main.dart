import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ui_login_out/screens/home.dart';
import 'firebase_options.dart';
import 'screens/Login.dart';
import 'screens/admin/admin_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduTalk',
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<DocumentSnapshot>? _userDocFuture;
  String? _cachedUid;
  bool _isCreatingUser = false;

  Future<DocumentSnapshot> _getUserDoc(String uid) {
    if (_userDocFuture == null || _cachedUid != uid) {
      _cachedUid = uid;
      _userDocFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    }
    return _userDocFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;

        // Chưa đăng nhập
        if (user == null) {
          _userDocFuture = null;
          _cachedUid = null;
          _isCreatingUser = false;
          return const LoginScreen();
        }

        // Đã đăng nhập — lấy role có cache
        return FutureBuilder<DocumentSnapshot>(
          future: _getUserDoc(user.uid),
          builder: (context, roleSnapshot) {
            // Trường hợp đang đợi tải dữ liệu từ Firestore
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            // Trường hợp xảy ra lỗi khi kết nối Firestore
            if (roleSnapshot.hasError) {
              // Đăng xuất nếu có lỗi
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            // Trường hợp lấy dữ liệu thành công và Document tồn tại trên Firestore
            if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
              final String role = roleSnapshot.data!.get('role') ?? 'user';
              final String name =
                  user.displayName ?? user.email?.split('@')[0] ?? 'Bạn';

              if (role == 'admin') {
                return const AdminLayout();
              }
              return HomeScreen(userName: name);
            }

            // Trường hợp Document không tồn tại (user mới)
            // Tránh tạo user nhiều lần
            if (roleSnapshot.connectionState == ConnectionState.done &&
                !_isCreatingUser) {
              _isCreatingUser = true;

              // Tạo document mới cho user
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .set({
                      'uid': user.uid,
                      'name': user.displayName ?? '',
                      'email': user.email ?? '',
                      'role': 'user',
                      'created_at': FieldValue.serverTimestamp(),
                    });

                // Reset cache để load lại với document mới
                if (mounted) {
                  setState(() {
                    _userDocFuture = null;
                    _cachedUid = null;
                    _isCreatingUser = false;
                  });
                }
              });
            }

            return const _LoadingScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF4DD0E1))),
    );
  }
}
