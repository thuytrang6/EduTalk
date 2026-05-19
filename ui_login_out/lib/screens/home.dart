import 'package:flutter/material.dart';
import 'PhanTich.dart';
import 'DuLieu.dart';
import 'ThaoLuan.dart';
import 'LichSu.dart';
import 'home_page.dart';
import 'Profile.dart';
import 'KetQua.dart';
import 'About.dart';
import 'ContactPage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f6fa),
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: pages),
          if (isShowingPhanTich && currentIndex == 2)
            Positioned.fill(
              child: PhanTichScreen(
                onBack: closeOverlayPage,
                onShowKetQua: openKetQua,
                totalScore: _totalScore, // ← THÊM DÒNG NÀY
                subjects: _subjects, // ← THÊM DÒNG NÀY
                scoresDetail: _scoresDetail, // ← THÊM DÒNG NÀY
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
      floatingActionButton: AnimatedScale(
        scale: currentIndex == 2 ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 25, 199, 170),
                Color.fromARGB(255, 34, 197, 197),
                Color.fromARGB(255, 46, 108, 189),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xff2563eb).withOpacity(0.22),
                blurRadius: 18,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            onPressed: () => _changeTab(2),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
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
            const SizedBox(width: 50),
            _navItem(Icons.history_rounded, "Lịch sử", 3),
            _navItem(Icons.person_rounded, "Cá nhân", 4),
          ],
        ),
      ),
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
}
