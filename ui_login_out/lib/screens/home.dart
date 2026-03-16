import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true, // Allows content to go behind the BottomAppBar
      body: Stack(
        children: [
          // Top Background Gradient - Adjusted height for better mobile fit
          Container(
            height: size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Xin chào,',
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                userName.isEmpty ? 'Khách' : userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('👋', style: TextStyle(fontSize: 22)),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology, color: Color(0xFF4DD0E1), size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Main Banner Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.yellow, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Sẵn sàng khám phá tương lai?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Hệ thống AI Random Forest đang chờ để phân tích dữ liệu của bạn.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bắt đầu tư vấn mới',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Quick Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context: context,
                          icon: Icons.history,
                          title: 'Lịch sử',
                          subtitle: 'Xem lại kết quả',
                          color: Colors.blue.shade100,
                          iconColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildQuickActionCard(
                          context: context,
                          icon: Icons.people_outline,
                          title: 'Thảo luận',
                          subtitle: 'Cộng đồng D30',
                          color: Colors.purple.shade100,
                          iconColor: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Hot Industries Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.trending_up, color: Colors.green, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Ngành Hot 2024',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text(
                                'Xem dữ liệu',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildIndustryItem(1, 'Công nghệ thông tin', '+15%', Colors.green),
                        const Divider(height: 20, thickness: 0.5),
                        _buildIndustryItem(2, 'Thiết kế vi mạch', '+25%', Colors.green),
                        const Divider(height: 20, thickness: 0.5),
                        _buildIndustryItem(3, 'Marketing số', '+10%', Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 110), // Increased space for bottom nav & FAB
                ],
              ),
            ),
          ),
        ],
      ),
      // FloatingActionButton - Better integrated for mobile
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
            ),
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryItem(int index, String name, String growth, Color growthColor) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: growthColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            growth,
            style: TextStyle(
              color: growthColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      height: 70,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 30,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Trang chủ', true),
          _buildNavItem(Icons.chat_bubble_rounded, 'Thảo luận', false),
          const SizedBox(width: 48), // Space for FAB
          _buildNavItem(Icons.history_rounded, 'Lịch sử', false),
          _buildNavItem(Icons.menu_rounded, 'Menu', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
