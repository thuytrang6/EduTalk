import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ui_login_out/screens/free_usage_store.dart';
import 'package:ui_login_out/services/payment_service.dart';
import '../models/user_model.dart';
import 'PhanTich.dart';
import 'DuLieu.dart';
import 'ThaoLuan.dart';
import 'LichSu.dart';
import 'home_page.dart';
import 'Profile.dart';
import 'KetQua.dart';
import 'About.dart';
import 'ContactPage.dart';
import 'Premium_screen.dart';
class HomeScreen extends StatefulWidget {
  final String userName;
  HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool isShowingPhanTich = false;
  bool isShowingKetQua = false;
  bool isShowingAbout = false;
  bool isShowingContact = false;

  String _predictedMajor = '';
  List<dynamic> _recommendations = [];
  List<int> _userScores = [];
  List<int> _majorRequirements = [];
  double _totalScore = 0.0;
  List<String> _subjects = [];
  List<double> _scoresDetail = [];

  final GlobalKey<DuLieuScreenState> duLieukey = GlobalKey();

  double _aiIconRight = 16;
  double _aiIconBottom = 90;

  @override
  void initState() {
    super.initState();
    _listenToUsageCount();
    _checkInitialPremiumStatus();
  }

  void _checkInitialPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final status = await PaymentService().checkPremiumStatus(user.uid);
      if (status != null && status['expired'] == true && mounted) {
        _showExpiryDialog(status['plan'] ?? 'Premium');
      }
    }
  }

  void _showExpiryDialog(String planName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_myejioos.json', // Sad/Expired animation
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 16),
            Text(
              "Gói $planName đã hết hạn",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Hãy gia hạn hoặc nâng cấp để tiếp tục trải nghiệm EduTalk Premium không giới hạn nhé!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Để sau", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563eb),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Nâng cấp ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  DateTime? _lastPremiumAt;
  bool _initialStateCaptured = false;

  void _listenToUsageCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists && mounted) {
              final userData = UserModel.fromDocument(snapshot);
              
              // Logic thông báo nâng cấp thành công (MoMo & Bank)
              if (!_initialStateCaptured) {
                // Lần đầu load app: Chỉ ghi nhớ thời điểm thanh toán gần nhất, không hiện dialog
                _lastPremiumAt = userData.premiumAt;
                _initialStateCaptured = true;
              } else {
                // Các lần update sau:
                // Nếu premiumAt mới xuất hiện HOẶC mới hơn cái cũ -> Vừa thanh toán thành công
                if (userData.premiumAt != null && 
                   (_lastPremiumAt == null || userData.premiumAt!.isAfter(_lastPremiumAt!))) {
                  
                  _lastPremiumAt = userData.premiumAt; // Cập nhật mốc mới nhất
                  _showUpgradeSuccessDialog(userData.currentPlan ?? "Premium");
                }
              }

              // Đồng bộ giá trị từ Firestore sang ValueNotifier global
              freeUsageCount.value = (3 - userData.usageCount).clamp(0, 3);
              
              // Đồng bộ toàn bộ thông tin User để xử lý Theme Premium
              currentUserNotifier.value = userData;
            }
          });
    }
  }

  void _showUpgradeSuccessDialog(String planName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Lottie.network(
              'https://lottie.host/825f385c-1971-463e-862d-94b79148d45e/v2t4VqE5xT.json', // Crown/Success animation
              height: 160,
              repeat: false,
            ),
            const SizedBox(height: 24),
            const Text(
              "Nâng cấp thành công!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Text(
              "Chào mừng bạn đến với cộng đồng EduTalk Premium $planName!\nTận hưởng trải nghiệm không giới hạn ngay bây giờ.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Bắt đầu trải nghiệm ngay 🚀", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get pages => [
    HomePage(
      onChangeTab: _changeTab,
      onOpenAbout: openAbout,
      onOpenContact: openContact,
    ),
    const ThaoLuanScreen(),
    DuLieuScreen(
      key: duLieukey,
      onChangeTab: _changeTab,
      onOPenPhanTich: _openPhanTich,
    ),
    const LichSuScreen(),
    ProfileScreen(),
  ];

  void onRestart() {
    setState(() {
      currentIndex = 2;
      isShowingKetQua = false;
      isShowingPhanTich = false;
      _predictedMajor = '';
      _recommendations = [];
      _userScores = [];
      _majorRequirements = [];
      _totalScore = 0.0;
    });
    duLieukey.currentState?.resetForm();
    duLieukey.currentState?.scrollToTop();
  }

  void _changeTab(int index) {
    if (currentIndex == index && !isShowingPhanTich) return;
    setState(() {
      currentIndex = index;
      isShowingPhanTich = false;
      isShowingKetQua = false;
      isShowingAbout = false;
      isShowingContact = false;
    });
    if (index == 2) {
      duLieukey.currentState?.resetForm();
    }
  }

  void _openPhanTich(
    double totalScore,
    List<String> subjects,
    List<double> scoresDetail,
  ) {
    setState(() {
      _totalScore = totalScore;
      _subjects = subjects;
      _scoresDetail = scoresDetail;
      isShowingPhanTich = true;
    });
  }

  void openKetQua(
    String major,
    List<dynamic> recommendations,
    List<int> userScores,
    List<int> majorRequirements,
  ) {
    // Ưu tiên Premium: Nếu là Premium Active, không bao giờ hiện SnackBar hết lượt.
    final bool isPremium = currentUserNotifier.value?.isPremiumActive ?? false;

    if (!isPremium && freeUsageCount.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bạn đã hết lượt dùng thử',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xffef4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    setState(() {
      _predictedMajor = major;
      _recommendations = recommendations;
      _userScores = userScores;
      _majorRequirements = majorRequirements;
      isShowingPhanTich = false;
      isShowingKetQua = true;
    });
  }

  void closeKetQua() {
    setState(() {
      currentIndex = 2;
      isShowingKetQua = false;
      isShowingPhanTich = true;
    });
  }

  void openAbout() => setState(() {
    isShowingAbout = true;
    isShowingContact = false;
  });

  void openContact() => setState(() {
    isShowingContact = true;
    isShowingAbout = false;
  });

  void closeExtraPage() => setState(() {
    isShowingAbout = false;
    isShowingContact = false;
  });

  void closeOverlayPage() => setState(() {
    currentIndex = 2;
    isShowingPhanTich = false;
    isShowingKetQua = false;
  });

  void openAIChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AIChatSheetGlobal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xfff5f6fa),
          body: Stack(
            clipBehavior:
                Clip.none, // Cho phép widget con tràn ra ngoài nếu cần
            children: [
              IndexedStack(index: currentIndex, children: pages),
              if (isShowingPhanTich && currentIndex == 2)
                Positioned.fill(
                  child: PhanTichScreen(
                    onBack: closeOverlayPage,
                    onShowKetQua: openKetQua,
                    totalScore: _totalScore,
                    subjects: _subjects,
                    scoresDetail: _scoresDetail,
                  ),
                ),
              if (isShowingKetQua && currentIndex == 2)
                Positioned.fill(
                  child: KetQuaScreen(
                    onBack: closeKetQua,
                    onRestart: onRestart,
                    predictedMajor: _predictedMajor,
                    recommendations: _recommendations,
                    userScores: _userScores,
                    majorRequirements: _majorRequirements,
                    totalScore: _totalScore,
                  ),
                ),
              if (isShowingAbout && currentIndex == 2)
                Positioned.fill(child: AboutPage(onBack: closeExtraPage)),
              if (isShowingContact && currentIndex == 2)
                Positioned.fill(child: ContactPage(onBack: closeExtraPage)),
            ],
          ),

          // SỬA ĐỔI: Sử dụng một Custom Bottom Navigation Stack để nút chính giữa nhô cao lên
          bottomNavigationBar: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip
                .none, // QUAN TRỌNG: Cho phép nút Phân Tích lọt ra khỏi Container thanh navi
            children: [
              // Khối nền trắng của thanh điều hướng (Height 72)
              Container(
                width: double.infinity,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 14,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.home_rounded, "Trang chủ", 0),
                    _navItem(Icons.chat_bubble_rounded, "Thảo luận", 1),

                    // Khoảng trống ở giữa để nhường chỗ cho nút nhô cao lên
                    const SizedBox(width: 70),

                    _navItem(Icons.history_rounded, "Lịch sử", 3),
                    _navItem(Icons.person_rounded, "Cá nhân", 4),
                  ],
                ),
              ),

              // ĐÃ SỬA: Đưa nút Phân tích tròn Gradient nhô hẳn lên trên (Tràn ra ngoài 22px)
              Positioned(
                top:
                    -22, // Đẩy lùi lên phía trên thanh navi 22 đơn vị để tạo hiệu ứng nổi bật hẳn
                child: _buildCenterGradientNavItem(
                  Icons.auto_awesome_rounded,
                  "",
                  2,
                ),
              ),
            ],
          ),
        ), // end Scaffold
        // Icon AI nổi trên tất cả kể cả navigator
        Positioned(
          right: _aiIconRight,
          bottom: _aiIconBottom,
          child: GestureDetector(
            onTap: openAIChatSheet,
            onPanUpdate: (details) {
              final size = MediaQuery.of(context).size;
              setState(() {
                _aiIconRight = (_aiIconRight - details.delta.dx).clamp(
                  0.0,
                  size.width - 100,
                );
                _aiIconBottom = (_aiIconBottom - details.delta.dy).clamp(
                  0.0,
                  size.height - 100,
                );
              });
            },
            child: Lottie.asset(
              'assets/Live chatbot.json',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xff2563eb),
                  size: 40,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool active = currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _changeTab(index),
      child: SizedBox(
        width: 68,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 26,
                color: active ? const Color(0xff2563eb) : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? const Color(0xff2563eb) : Colors.grey,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget nút tròn gradient Phân Tích nhô cao lên hẳn
  Widget _buildCenterGradientNavItem(IconData icon, String label, int index) {
    final bool active = currentIndex == index;
    return GestureDetector(
      onTap: () => _changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vòng tròn Gradient nhô hẳn ra ngoài thanh điều hướng
          Container(
            width: 54, // Tăng kích thước vòng tròn lên 54 để tạo điểm nhấn
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 25, 199, 170),
                  Color.fromARGB(255, 34, 197, 197),
                  Color.fromARGB(255, 46, 108, 189),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xff2563eb,
                  ).withOpacity(0.35), // Tăng đổ bóng cho cảm giác 3D tách biệt
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28, // Icon bên trong to rõ ràng hơn
            ),
          ),
          const SizedBox(height: 5),
          // Nhãn chữ nằm gọn bên dưới
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xff2563eb) : Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AIChatSheetGlobal extends StatefulWidget {
  const _AIChatSheetGlobal();

  @override
  State<_AIChatSheetGlobal> createState() => _AIChatSheetGlobalState();
}

class _AIChatSheetGlobalState extends State<_AIChatSheetGlobal> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "ai",
      "text":
          "Xin chào! Mình là trợ lý AI hệ thống. Bạn cần mình giải đáp hay hỗ trợ gì lúc này không? ✨",
    },
  ];

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _chatController.clear();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "sender": "ai",
            "text":
                "Cảm ơn câu hỏi của bạn! Tính năng kết nối API AI đang được thiết lập, mình sẽ sớm trả lời bạn thật chi tiết nhé! 🤖",
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xff2563eb),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trợ lý EduTalk AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Đang trực tuyến",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg["sender"] == "user";
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xff2563eb) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                      ),
                      child: Text(
                        msg["text"],
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 12,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Hỏi AI bất cứ điều gì...",
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xff2563eb),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
