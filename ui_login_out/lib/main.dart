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
  Future<DocumentSnapshot>? _docFuture;
  String? _cachedUid;

  Future<DocumentSnapshot> _getDoc(String uid) {
    if (_cachedUid != uid || _docFuture == null) {
      _cachedUid = uid;
      _docFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    }
    return _docFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;
        print('AUTH STATE: user = ${user?.uid}');

        if (user == null) {
          _docFuture = null;
          _cachedUid = null;
          return const LoginScreen();
        }

        final String name =
            user.displayName ?? user.email?.split('@')[0] ?? 'Bạn';

        return FutureBuilder<DocumentSnapshot>(
          future: _getDoc(user.uid),
          builder: (context, docSnapshot) {
            print(
              'DOC STATE: ${docSnapshot.connectionState} hasError=${docSnapshot.hasError} exists=${docSnapshot.data?.exists}',
            );

            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (docSnapshot.hasError) {
              print('DOC ERROR: ${docSnapshot.error}');
              return HomeScreen(userName: name);
            }

            if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
              print('DOC: không tồn tại → HomeScreen');
              return HomeScreen(userName: name);
            }

            final String role = docSnapshot.data!.get('role') ?? 'user';
            print('DOC: role=$role → vào HomeScreen');
            if (role == 'admin') return const AdminLayout();
            return HomeScreen(userName: name);
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
