// import 'package:flutter/material.dart';
// import 'DuLieu.dart';
// import 'ThaoLuan.dart';
// import 'LichSu.dart';
// import 'menu_drawer.dart';
// import 'home_page.dart';
// import 'Profile.dart';

// class HomeScreen extends StatefulWidget {
//   final String userName;

//   const HomeScreen({super.key, required this.userName});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int currentIndex = 0;

//   final List<Widget> pages = [
//     const HomePage(),
//     const ThaoLuanScreen(),
//     const DuLieuScreen(),
//     const LichSuScreen(),
//     const ProfileScreen(),
//   ];
//   void _changeTab(int index) {
//     setState(() {
//       currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: const Color(0xfff5f6fa),
//       body: IndexedStack(index: currentIndex, children: pages),

//       floatingActionButton: Container(
//         height: 74,
//         width: 74,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.25),
//               blurRadius: 16,
//               spreadRadius: 2,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: FloatingActionButton(
//           elevation: 0,
//           backgroundColor: const Color(0xff1da1f2),
//           shape: const CircleBorder(),
//           onPressed: () => _changeTab(2),
//           child: const Icon(Icons.psychology, color: Colors.white, size: 32),
//         ),
//       ),

//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 12,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomAppBar(
//           shape: const CircularNotchedRectangle(),
//           notchMargin: 10,
//           elevation: 0,
//           color: Colors.white,
//           child: SizedBox(
//             height: 72,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _navItem(Icons.home_outlined, "Trang chủ", 0),
//                 _navItem(Icons.forum_outlined, "Thảo luận", 1),

//                 const SizedBox(width: 54),

//                 _navItem(Icons.history, "Lịch sử", 3),
//                 _navItem(Icons.person_outline, "Cá nhân", 4),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _navItem(IconData icon, String label, int index) {
//     final bool active = currentIndex == index;

//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: () => _changeTab(index),
//       child: SizedBox(
//         width: 64,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 27,
//               color: active ? const Color(0xff2563eb) : Colors.grey,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: active ? FontWeight.w600 : FontWeight.w500,
//                 color: active ? const Color(0xff2563eb) : Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'DuLieu.dart';
import 'ThaoLuan.dart';
import 'LichSu.dart';
import 'home_page.dart';
import 'Profile.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    HomePage(onChangeTab: _changeTab),
    const ThaoLuanScreen(),
    const DuLieuScreen(),
    const LichSuScreen(),
    const ProfileScreen(),
  ];

  void _changeTab(int index) {
    if (currentIndex == index) return;
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f6fa),
      body: IndexedStack(index: currentIndex, children: pages),

      floatingActionButton: AnimatedScale(
        scale: currentIndex == 2 ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: Container(
          // nút giữa
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
                color: const Color(0xff2563eb).withOpacity(0.22),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent, // 👈 QUAN TRỌNG
            //shadowColor: Colors.transparent,
            // backgroundColor: const Color(0xff2563eb),
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
        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: const [
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
