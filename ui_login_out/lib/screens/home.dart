import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ui_login_out/screens/free_usage_store.dart';
import 'PhanTich.dart';
import 'DuLieu.dart';
import 'ThaoLuan.dart';
import 'LichSu.dart';
import 'home_page.dart';
import 'Profile.dart';
import 'KetQua.dart';
import 'About.dart';
import 'ContactPage.dart';
import 'ai_chat_screen.dart';

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
    // Trừ 1 lượt free
    final currentCount = freeUsageCount.value;
    if (currentCount > 0) {
      freeUsageCount.value = currentCount - 1;
    }

    // Nếu sau khi trừ còn 0 lượt → hiện thông báo hết lượt
    if (freeUsageCount.value == 0) {
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
      builder: (_) => const AIChatSheet(),
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


