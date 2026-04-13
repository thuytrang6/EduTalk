import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Lưu trữ file ảnh đã chọn

  // Premium Palette
  static const Color primaryNavy = Color(0xFF001C3D);
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color warmBg = Color(0xFFFFF9EE);

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã cập nhật ảnh đại diện mới!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi khi chọn ảnh. Vui lòng cấp quyền!"),
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: Colors.white.withOpacity(0.2),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Thay đổi ảnh đại diện",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pickerOption(
                    icon: Icons.photo_library_rounded,
                    label: "Thư viện",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _pickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: "Máy ảnh",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
                //border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                icon,
                color: const Color.fromARGB(255, 255, 255, 255),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
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
      height: 340,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 46, 108, 189),
            Color.fromARGB(255, 25, 199, 170),
            Color.fromARGB(255, 34, 197, 197),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingScreen()),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        const SizedBox(height: 60),
        _buildAvatarSection(),
        const SizedBox(height: 16),
        _buildUserIdentity(),
        const SizedBox(height: 30),
        _buildPremiumCard(),
        const SizedBox(height: 20),
        _buildInfoForm(),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _showImagePickerOptions,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? Text(
                        widget.username.isNotEmpty
                            ? widget.username[0].toUpperCase()
                            : "Q",
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff06b6d4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdentity() {
    return Column(
      children: [
        Text(
          widget.username,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Thành viên D30",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: warmBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFFFE58F).withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentOrange, Color(0xFFFF6D00)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nâng cấp Premium ✨",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: primaryNavy,
                      ),
                    ),
                    Text(
                      "Sử dụng không giới hạn • Hỗ trợ ưu tiên",
                      style: TextStyle(fontSize: 12, color: Color(0xFF5A6B81)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(),
          const SizedBox(height: 20),
          _buildPremiumButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 10,
              width: 600,
              decoration: BoxDecoration(
                color: accentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "3/3 lượt",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [accentOrange, Color(0xFFFF5D00)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5D00).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final targetTab = await Navigator.push<int>(
            context,
            MaterialPageRoute(
              builder: (_) => PremiumScreen(onTabChange: widget.onChangeTab),
            ),
          );
          if (targetTab != null && widget.onChangeTab != null)
            widget.onChangeTab!(targetTab);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "Xem gói Premium",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
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
                color: Color(0xFF2563EB),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                "Thông tin cá nhân",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: primaryNavy,
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
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
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
            // ĐÂY LÀ PHẦN CHỈNH MÀU CHỮ KHI ĐANG NHẬP
            style: const TextStyle(
              color: Colors.black, // Chữ khi nhập sẽ có màu đen
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xff94a3b8)),
              // Chữ gợi ý vẫn màu xám
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
                  color: Color(0xFF2563EB),
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
