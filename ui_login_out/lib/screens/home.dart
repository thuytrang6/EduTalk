import 'package:flutter/material.dart';
import 'package:ui_login_out/screens/PhanTich.dart';
import 'DuLieu.dart';
import 'ThaoLuan.dart';
import 'LichSu.dart';
import 'home_page.dart';
import 'Profile.dart';
import 'KetQua.dart';
import 'ThongKeTs.dart';
class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool isShowingPhanTich = false;
  bool isShowingKetQua = false;

  late final List<Widget> pages = [
    HomePage(onChangeTab: _changeTab),
    const ThaoLuanScreen(),
    DuLieuScreen(onChangeTab: _changeTab, onOPenPhanTich: openPhanTich),
    const LichSuScreen(),
    ProfileScreen(username: widget.userName, onChangeTab: _changeTab),

  ];

  void _changeTab(int index) {
    if (currentIndex == index && !isShowingPhanTich) return;

    setState(() {
      currentIndex = index;
      isShowingPhanTich = false;
    });
  }

  void openPhanTich() {
    setState(() {
      currentIndex = 2;
      isShowingPhanTich = true;
      isShowingKetQua = false;
    });
  }

  void openKetQua() {
    setState(() {
      currentIndex = 2;
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

  void closeOverlayPage() {
    setState(() {
      currentIndex = 2;
      isShowingPhanTich = false;
      isShowingKetQua = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f6fa),
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: pages),
          if (isShowingPhanTich)
            Positioned.fill(
              child: PhanTichScreen(
                onBack: closeOverlayPage,
                onShowKetQua: openKetQua,
              ),
            ),
          if (isShowingKetQua)
            Positioned.fill(
              child: KetQuaScreen(
                onBack: closeKetQua,
                onRestart: () {
                  setState(() {
                    currentIndex = 2;
                    isShowingKetQua = false;
                    isShowingPhanTich = true;
                  });
                },
              ),
            ),
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
