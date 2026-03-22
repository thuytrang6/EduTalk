import 'package:flutter/material.dart';
import 'package:ui_login_out/screens/DuLieu.dart';
import 'package:ui_login_out/screens/LichSu.dart';
import 'package:ui_login_out/screens/ThaoLuan.dart';
import 'package:ui_login_out/screens/free_usage_store.dart';
import 'Premium_screen.dart';
import 'ThongKeTs.dart';
class HomePage extends StatelessWidget {
  final ValueChanged<int>? onChangeTab;
  const HomePage({super.key, this.onChangeTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // hiệu ứng cuộn mượt mà
          //   // cho phép cuộn nếu nội dung vượt quá màn hình
          child: Column(
            children: [
              Stack(
                clipBehavior:
                    Clip.none, // cho phép phần tử con vượt ra ngoài Stack
                children: [
                  Container(
                    height: 550,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff1e3a8a),
                          Color(0xff312e81),
                          Color(0xff0f766e),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Bạn 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        freeAcountCard(context),
                        const SizedBox(height: 20),
                        BatDauTuVan(context),
                      ],
                    ),
                  ),

                  // 🔹 CARD NỔI LÊN
                  Positioned(
                    top: 450, // chỉnh số này để nổi lên
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: homeCard(
                            context,
                            icon: Icons.history,
                            title: "Lịch sử",
                            subtitle: "Xem lại kết quả",
                            iconColor: const Color(0xff2563eb),
                            iconBackground: const Color(0xffeff6ff),
                            onTap: () {
                              onChangeTab?.call(3);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: homeCard(
                            context,
                            icon: Icons.forum,
                            title: "Thảo luận",
                            subtitle: "Trao đổi với bạn bè",
                            iconColor: const Color(0xff059669),
                            iconBackground: const Color(0xffd1fae5),
                            onTap: () {
                              onChangeTab?.call(1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    NganhHot(context),
                    const SizedBox(height: 16),
                    KhamPhaThem(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
          // ),
        ),
      ),
    );
  }

  Widget KhamPhaThem(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: const Color(0xff2563eb), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Khám phá thêm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          moreItems(
            context,
            icon: Icons.bar_chart,
            iconColor: const Color(0xff2563eb),
            iconBackground: const Color(0xffeff6ff),
            title: "Dữ liệu & Báo cáo",
            subtitle: "Thống kê tuyển sinh",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThongKeTs(onTabChange: onChangeTab),
                ),
              );
            },
          ),

          const SizedBox(height: 10),
          moreItems(
            context,
            icon: Icons.info_outline,
            iconColor: const Color(0xff9333ea),
            iconBackground: const Color(0xfff5f3ff),
            title: "Về chúng tôi",
            subtitle: "Giới thiệu về D30 AI",
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const VeChungToiScreen(),
              //   ),
              // );
            },
          ),

          const SizedBox(height: 10),
          moreItems(
            context,
            icon: Icons.phone_outlined,
            iconColor: const Color(0xff0f766e),
            iconBackground: const Color(0xffecfeff),
            title: "Liên hệ hỗ trợ",
            subtitle: "Gửi câu hỏi cho chúng tôi",
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const LienHeHoTroScreen(),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }

  Widget moreItems(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xfff8fafc),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffeef2f7), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget NganhHot(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: const Color(0xff22c55e), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Ngành Hot 2024",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThongKeTs(onTabChange: onChangeTab),
                    ),
                  );
                },
                child: Text(
                  "Xem dữ liệu",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2563eb),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          hotItems(index: "1", title: "Công nghệ thông tin", percent: 15),
          const SizedBox(height: 10),
          hotItems(index: "2", title: "Y tế", percent: 12),
          const SizedBox(height: 10),
          hotItems(index: "3", title: "Giáo dục", percent: 10),
        ],
      ),
    );
  }

  Widget hotItems({
    required String index,
    required String title,
    required int percent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffeef2f7), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                index,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffd1fae5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "+$percent%",
              style: const TextStyle(
                color: Color(0xff059669),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget freeAcountCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 110, 104, 104).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffeab308).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tài khoản miễn phí",
                  style: TextStyle(
                    color: Color(0xffffe08a),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder(
                  valueListenable: freeUsageCount,
                  builder: (context, value, _) {
                    return Text(
                      "Số lượt $value/3 dùng thử",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 254, 187, 54),
                  Color.fromARGB(255, 255, 155, 48),
                  Color.fromARGB(255, 244, 130, 0),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Nâng cấp",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BatDauTuVan(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            "✨ Chọn ngành đúng sáng tương lai",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Hệ thống AI của chúng tôi đang chờ để phân tích dữ liệu cùng bạn.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent, // để giữ nguyên hiệu ứng gradient
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                onChangeTab?.call(2);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 25, 199, 170),
                      Color.fromARGB(255, 34, 197, 197),
                      Color.fromARGB(255, 46, 108, 189),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Bắt đầu tư vấn mới ->",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget homeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return InkWell(
      // cho hiệu ứng nhấn
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
