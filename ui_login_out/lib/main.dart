import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Nhận Deep Link: $uri');
      if (uri.scheme == 'edutalk' && uri.host == 'payment-result') {
        _handlePaymentResult(uri);
      }
    });
  }

  void _handlePaymentResult(Uri uri) {
    // resultCode = 0 là thành công theo chuẩn MoMo
    final resultCode = uri.queryParameters['resultCode'];
    
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    if (resultCode == '0') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Chúc mừng!"),
          content: const Text("Giao dịch thành công. Tài khoản của bạn đang được nâng cấp Premium!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Bắt đầu trải nghiệm"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thanh toán đã bị hủy hoặc gặp lỗi."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'EduTalk',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
