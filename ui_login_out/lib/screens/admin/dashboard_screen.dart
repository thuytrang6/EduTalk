import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, int> stats = {
    'totalUsers': 1,
    'premiumUsers': 0,
    'totalPosts': 0,
    'activeUsers': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildHeader(),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEA580C), Color(0xFFDC2626), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quản trị viên', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _buildStatCard(Icons.people_alt_rounded, stats['totalUsers'].toString(), 'Tổng người dùng'),
              _buildStatCard(Icons.workspace_premium_rounded, stats['premiumUsers'].toString(), 'Premium Users', isAmber: true),
              _buildStatCard(Icons.chat_bubble_rounded, stats['totalPosts'].toString(), 'Bài viết forum', isPink: true),
              _buildStatCard(Icons.how_to_reg_rounded, stats['activeUsers'].toString(), 'Hoạt động'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, {bool isAmber = false, bool isPink = false}) {
    Color iconColor = Colors.white70;
    if (isAmber) iconColor = Colors.amber[300]!;
    if (isPink) iconColor = Colors.pink[200]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildQuickActionSection(),
          const SizedBox(height: 16),
          _buildActivitySection(),
          const SizedBox(height: 16),
          _buildSystemHealthSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActionSection() {
    return _buildContainerSection(
      title: 'Quản lý nhanh',
      icon: Icons.trending_up_rounded,
      iconColor: Colors.orange,
      child: Column(
        children: [
          _buildActionItem(
            Icons.people_alt_rounded,
            'Quản lý người dùng',
            '${stats['totalUsers']} người dùng',
            Colors.orange,
          ),
          _buildActionItem(
            Icons.chat_bubble_rounded,
            'Quản lý forum',
            '${stats['totalPosts']} bài viết',
            Colors.purple,
          ),
          _buildActionItem(
            Icons.workspace_premium_rounded,
            'Quản lý Premium',
            '${stats['premiumUsers']} thành viên',
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Xem',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return _buildContainerSection(
      title: 'Hoạt động gần đây',
      icon: Icons.show_chart_rounded,
      iconColor: Colors.blue,
      child: Column(
        children: [
          _buildRecentItem(
            Icons.person_add_rounded,
            'Người dùng mới đăng ký',
            'Vài phút trước',
            Colors.blue[100]!,
            Colors.blue,
          ),
          _buildRecentItem(
            Icons.chat_bubble_rounded,
            'Bài viết mới trong forum',
            '15 phút trước',
            Colors.purple[100]!,
            Colors.purple,
          ),
          _buildRecentItem(
            Icons.workspace_premium_rounded,
            'Nâng cấp Premium thành công',
            '1 giờ trước',
            Colors.amber[100]!,
            Colors.amber[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(IconData icon, String title, String time, Color bgColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSystemHealthSection() {
    return _buildContainerSection(
      title: 'Tình trạng hệ thống',
      icon: Icons.radio_button_checked_rounded,
      iconColor: Colors.green,
      child: Column(
        children: [
          _buildHealthRow('Database'),
          _buildHealthRow('API Server'),
          _buildHealthRow('Storage'),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Hoạt động tốt',
              style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}