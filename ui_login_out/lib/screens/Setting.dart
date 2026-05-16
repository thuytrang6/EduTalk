import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isNotificationEnabled = true;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(children: [_buildHeader(), _buildMainContent()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [Color(0xff1e3a8a), Color(0xff312e81), Color(0xff0f766e)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Color(0xff4DD0E1),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cài đặt",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Tùy chỉnh ứng dụng theo ý bạn",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        const SizedBox(height: 180),
        _buildSection(
          title: "Cài đặt chung",
          items: [
            _buildToggleItem(
              icon: Icons.notifications_none_rounded,
              iconColor: const Color(0xff2563eb),
              bgColor: const Color(0xffeff6ff),
              title: "Thông báo",
              subtitle: "Nhận thông báo từ ứng dụng",
              value: _isNotificationEnabled,
              onChanged: (val) => setState(() => _isNotificationEnabled = val),
            ),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xff9333ea),
              bgColor: const Color(0xfff5f3ff),
              title: "Chế độ tối",
              subtitle: "Đang phát triển",
              value: _isDarkMode,
              onChanged: (val) => setState(() => _isDarkMode = val),
            ),
            _buildNavigationItem(
              icon: Icons.language_rounded,
              iconColor: const Color(0xff059669),
              bgColor: const Color(0xffecfeff),
              title: "Ngôn ngữ",
              subtitle: "Tiếng Việt",
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: "Bảo mật & Quyền riêng tư",
          items: [
            _buildNavigationItem(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xfff59e0b),
              bgColor: const Color(0xfffff7ed),
              title: "Đổi mật khẩu",
              subtitle: "Cập nhật mật khẩu của bạn",
              onTap: () {},
            ),
            _buildNavigationItem(
              icon: Icons.security_outlined,
              iconColor: const Color(0xff6366f1),
              bgColor: const Color(0xffeef2ff),
              title: "Chính sách bảo mật",
              subtitle: "Xem cách chúng tôi bảo vệ dữ liệu",
              onTap: () {},
            ),
            _buildNavigationItem(
              icon: Icons.description_outlined,
              iconColor: const Color(0xff06b6d4),
              bgColor: const Color(0xffecfeff),
              title: "Điều khoản sử dụng",
              subtitle: "Xem điều khoản & điều kiện",
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: "Hỗ trợ",
          items: [
            _buildNavigationItem(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xffec4899),
              bgColor: const Color(0xfffdf2f8),
              title: "Trung tâm trợ giúp",
              subtitle: "Câu hỏi thường gặp & hướng dẫn",
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          items: [
            _buildNavigationItem(
              icon: Icons.logout_rounded,
              iconColor: const Color(0xffef4444),
              bgColor: const Color(0xfffef2f2),
              title: "Đăng xuất",
              subtitle: "Thoát khỏi tài khoản hiện tại",
              titleColor: const Color(0xffef4444),
              onTap: () {},
            ),
            _buildNavigationItem(
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xffef4444),
              bgColor: const Color(0xfffef2f2),
              title: "Xóa tài khoản",
              subtitle: "Xóa vĩnh viễn tài khoản và dữ liệu",
              titleColor: const Color(0xffef4444),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "AI Tư vấn tuyển sinh",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const Text(
          "Phiên bản 1.0.0",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSection({String? title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1e293b),
                ),
              ),
            ),
          if (title != null) const Divider(height: 1, color: Color(0xfff1f5f9)),
          ...items.asMap().entries.map((entry) {
            int idx = entry.key;
            Widget item = entry.value;
            return Column(
              children: [
                item,
                if (idx < items.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 70),
                    child: Divider(height: 1, color: Color(0xfff1f5f9)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIcon(icon, iconColor, bgColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xff2563eb),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildIcon(icon, iconColor, bgColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: titleColor ?? const Color(0xff1e293b),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
