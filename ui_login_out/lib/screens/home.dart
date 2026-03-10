import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(title: const Text('Home'), leading: Icon(Icons.home)),
    //   body: Container(
    //     decoration: const BoxDecoration(
    //       gradient: LinearGradient(
    //         colors: [
    //           Color(0xFF1e3a8a),
    //           Color(0xFF4c1d95),
    //           Color(0xFF0f766e),
    //           Color(0xFF1e40af),
    //         ],
    //       ),
    //     ),
    //     child: const Column(
    //       children: [
    //         Text(
    //           'CHÀO MỪNG BẠN ĐẾN VỚI APP',
    //           style: TextStyle(
    //             fontSize: 20,
    //             fontWeight: FontWeight.bold,
    //             color: Colors.white,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return MaterialApp(debugShowCheckedModeBanner: false, home: BNav());
  }
}

class BNav extends StatefulWidget {
  @override
  _BNavState createState() => _BNavState();
}

class _BNavState extends State<BNav> {
  final GlobalKey<ScaffoldState> _menuKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  static List<Widget> _children = <Widget>[
    TrangChu(),
    ThaoLuan(),
    LichSu(),
    Menu(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 24),

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 3) {
            _menuKey.currentState?.openEndDrawer();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang Chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Thảo Luận'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch Sử'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),

      endDrawer: Drawer(
        child: Column(
          children: const [
            DrawerHeader(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(color: Color.fromARGB(255, 7, 34, 57)),
              child: Text(
                'Tên user',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Dữ liệu & Báo cáo'),
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Về chúng tôi'),
            ),
            ListTile(leading: Icon(Icons.phone), title: Text('Liên hệ hỗ trợ')),
            Spacer(),
            ListTile(leading: Icon(Icons.logout), title: Text('Đăng Xuất')),
          ],
        ),
      ),
    );
  }
}

class TrangChu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1e3a8a),
            Color(0xFF4c1d95),
            Color(0xFF0f766e),
            Color(0xFF1e40af),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'CHÀO MỪNG BẠN ĐẾN VỚI APP',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ThaoLuan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class LichSu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
