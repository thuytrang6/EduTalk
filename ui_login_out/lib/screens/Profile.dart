import 'package:flutter/material.dart';
import 'Setting.dart';
import 'Premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final ValueChanged<int>? onChangeTab;

  const ProfileScreen({super.key, this.username = "Name", this.onChangeTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: "example@email.com");
    _phoneController = TextEditingController(text: "0123456789");
    _dobController = TextEditingController(text: "01/01/2000");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            _buildHeaderBackground(),
            _buildSettingsButton(),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [Color(0xff1e3a8a), Color(0xff1e3a8a), Color(0xff0f766e)],
          stops: [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        const SizedBox(height: 50),
        _buildAvatarSection(),
        const SizedBox(height: 12),
        _buildUserIdentity(),
        const SizedBox(height: 25),
        _buildPremiumCard(),
        const SizedBox(height: 20),
        _buildInfoForm(),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 65,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.username.isNotEmpty
                    ? widget.username[0].toUpperCase()
                    : "Q",
                style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xff06b6d4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserIdentity() {
    return Column(
      children: [
        Text(
          widget.username,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard() {
    const Color cardBg = Color(0xFFFFF9EE);
    const Color cardBorder = Color(0xFFFFE08A);
    const Color navyTitle = Color(0xFF14213D);
    const Color grayDescription = Color(0xFF5C6470);

    const Color premiumOrangeLight = Color.fromARGB(255, 254, 187, 54);
    const Color premiumOrange = Color.fromARGB(255, 255, 155, 48);
    const Color premiumOrangeDark = Color.fromARGB(255, 244, 130, 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cardBorder.withOpacity(0.65), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: premiumOrangeDark.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      premiumOrangeLight,
                      premiumOrange,
                      premiumOrangeDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: premiumOrange.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            "Nâng cấp Premium",
                            style: TextStyle(
                              color: navyTitle,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.auto_awesome,
                          color: premiumOrange,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Sử dụng không giới hạn • Tính năng cao cấp • Hỗ trợ ưu tiên",
                      style: TextStyle(
                        color: grayDescription,
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE7B0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            premiumOrangeLight,
                            premiumOrange,
                            premiumOrangeDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "3/3 lượt",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [premiumOrangeLight, premiumOrange, premiumOrangeDark],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: premiumOrangeDark.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                final targetTab = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PremiumScreen(onTabChange: widget.onChangeTab),
                  ),
                );

                if (targetTab != null && widget.onChangeTab != null) {
                  widget.onChangeTab!(targetTab);
                }
              },
              icon: const Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                "Xem gói Premium",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_pin_outlined,
                color: Color(0xff2563eb),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                "Thông tin cá nhân",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1e3a8a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            "Họ và tên",
            "Nhập tên của bạn",
            Icons.person_outline,
            _nameController,
          ),
          _buildTextField(
            "Email",
            "example@email.com",
            Icons.email_outlined,
            _emailController,
          ),
          _buildTextField(
            "Số điện thoại",
            "0385xxxxxxx",
            Icons.phone_outlined,
            _phoneController,
          ),
          _buildTextField(
            "Ngày sinh",
            "DD/MM/YYYY",
            Icons.calendar_today_outlined,
            _dobController,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    IconData icon,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff1e293b),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Color(0xff94a3b8)),
              prefixIcon: Icon(icon, size: 22, color: const Color(0xff94a3b8)),
              filled: true,
              fillColor: const Color(0xfff8fafc),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffe2e8f0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffe2e8f0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xff2563eb),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
