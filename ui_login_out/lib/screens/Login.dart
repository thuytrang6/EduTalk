import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../services/auth_service.dart';
import '/screens/Register.dart';
import 'admin/admin_layout.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // 👉 HÀM MỚI: TỰ KIỂM TRA ROLE VÀ CHUYỂN TRANG
  Future<void> _checkRoleAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Mò lên Firestore lấy thông tin role
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        String role = 'user';
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          role = data['role'] ?? 'user';
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (role == 'admin') {
          // Ép buộc chuyển hẳn sang Admin Panel, xóa sạch lịch sử trang Login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminLayout()),
            (route) => false,
          );
        } else {
          // Nếu là user thường, chuyển sang AuthGate và xóa lịch sử trang
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Lỗi phân quyền: $e");
    }
  }

  void _handleLogin() async {
    String email = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, dynamic>? result =
        await _authService.login(email, password) as Map<String, dynamic>?;

    if (!mounted) return;

    if (result == null || result["status"] != "success") {
      setState(() => _isLoading = false);
      _showError(result?["status"]?.toString() ?? "Đăng nhập thất bại");
      return;
    }

    // Đăng nhập Auth thành công -> Gọi hàm check Role
    _checkRoleAndNavigate();
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final Map<String, dynamic> result = await _authService.signInWithGoogle();

    if (!mounted) return;

    if (result["status"] != "success") {
      setState(() => _isLoading = false);
      _showError(result["status"]?.toString() ?? "Đăng nhập thất bại");
      return;
    }

    // Đăng nhập Auth thành công -> Gọi hàm check Role
    _checkRoleAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 80,
                        color: Color(0xFF4DD0E1),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Chào mừng trở lại!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EMAIL',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _userController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: Colors.white70,
                              ),
                              hintText: 'Nhập email của bạn...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'MẬT KHẨU',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.white70,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure; 
                                  });
                                },
                              ),
                              hintText: '........',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "HOẶC",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _handleGoogleLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.05),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _GoogleIcon(),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tiếp tục với Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4DD0E1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.75);

    canvas.drawArc(
      rect,
      3.14 * 1.1,
      3.14 * 0.8,
      true,
      Paint()..color = const Color(0xFFEA4335),
    );
    canvas.drawArc(
      rect,
      3.14 * 1.9,
      3.14 * 0.55,
      true,
      Paint()..color = const Color(0xFF4285F4),
    );
    canvas.drawArc(
      rect,
      3.14 * 0.0,
      3.14 * 0.55,
      true,
      Paint()..color = const Color(0xFFFBBC05),
    );
    canvas.drawArc(
      rect,
      3.14 * 0.55,
      3.14 * 0.55,
      true,
      Paint()..color = const Color(0xFF34A853),
    );

    canvas.drawCircle(Offset(cx, cy), r * 0.45, Paint()..color = Colors.white);

    final tabRect = Rect.fromLTWH(cx, cy - r * 0.18, r * 0.72, r * 0.36);
    canvas.drawRect(tabRect, Paint()..color = const Color(0xFF4285F4));

    final innerTab = Rect.fromLTWH(cx, cy - r * 0.18, r * 0.45, r * 0.36);
    canvas.drawRect(innerTab, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}