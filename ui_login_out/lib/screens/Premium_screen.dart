import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  final ValueChanged<int>? onTabChange;

  const PremiumScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    const int remainingTrials = 3;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(remainingTrials),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildComparisonCard(),
                  const SizedBox(height: 20),
                  _buildPricingPlans(),
                  const SizedBox(height: 20),
                  _buildGuaranteeCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  void _goToTab(BuildContext context, int index) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onTabChange?.call(index);
    });
  }

  Widget _buildFab(BuildContext context) {
    return InkWell(
      onTap: () => _goToTab(context, 2),
      borderRadius: BorderRadius.circular(35),
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
              color: const Color(0xff2563eb).withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
          _navItem(context, Icons.home_rounded, "Trang chủ", false, 0),
          _navItem(context, Icons.chat_bubble_rounded, "Thảo luận", false, 1),
          const SizedBox(width: 50),
          _navItem(context, Icons.history_rounded, "Lịch sử", false, 3),
          _navItem(context, Icons.person_rounded, "Cá nhân", true, 4),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      IconData icon,
      String label,
      bool active,
      int index,
      ) {
    return InkWell(
      onTap: () {
        if (!active) {
          _goToTab(context, index);
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: active ? const Color(0xff2563eb) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? const Color(0xff2563eb) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int trials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF8F00),
            Color(0xFFFF5D00),
            Color(0xFFE6007E),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFD700),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Nâng cấp Premium",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Trải nghiệm đầy đủ sức mạnh của D30 AI",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFCC5500).withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: const [
                Text(
                  "Lượt dùng thử còn lại",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "3 / 3",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "...",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 30,
                    height: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "So sánh gói dịch vụ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF14213D),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                _ComparisonItem(
                  title: "Miễn phí: 3 lần tư vấn",
                  subtitle: "Chỉ được sử dụng 3 lần đầu tiên",
                  isPositive: false,
                ),
                _ComparisonItem(
                  title: "Premium: Không giới hạn",
                  subtitle: "Tư vấn không giới hạn số lần",
                  isPositive: true,
                ),
                _ComparisonItem(
                  title: "AI phân tích chuyên sâu",
                  subtitle: "Độ chính xác cao hơn với mô hình nâng cao",
                  isPositive: true,
                ),
                _ComparisonItem(
                  title: "Lưu lịch sử vĩnh viễn",
                  subtitle: "Không bị giới hạn số lượng kết quả lưu trữ",
                  isPositive: true,
                ),
                _ComparisonItem(
                  title: "Hỗ trợ ưu tiên",
                  subtitle: "Được hỗ trợ nhanh chóng qua nhiều kênh",
                  isPositive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      children: [
        _buildPlanCard(
          title: "Gói Tháng",
          subtitle: "Linh hoạt, thử nghiệm",
          price: "99.000",
          unit: "đ/tháng",
          details: "Tự động gia hạn hàng tháng",
          color: const Color(0xFF2563EB),
          icon: Icons.flash_on_rounded,
          buttonIcon: Icons.auto_awesome_rounded,
          buttonText: "Mua gói Tháng",
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: "Gói Năm",
          subtitle: "Tiết kiệm 40% - Tốt nhất",
          price: "699.000",
          unit: "đ/năm",
          details: "Chỉ ~58.000đ/tháng",
          color: const Color(0xFFFF8000),
          icon: Icons.shield_rounded,
          buttonIcon: Icons.workspace_premium_rounded,
          buttonText: "Mua gói Năm",
          isBestValue: true,
          oldPrice: "1.188.000đ",
          savings: "Tiết kiệm 489.000đ",
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: "Gói Trọn Đời",
          subtitle: "Một lần thanh toán, sử dụng mãi mãi",
          price: "1.999.000",
          unit: "đ",
          details: "Thanh toán một lần, không cần gia hạn",
          color: const Color(0xFF8B5CF6),
          icon: Icons.workspace_premium_rounded,
          buttonIcon: Icons.workspace_premium_rounded,
          buttonText: "Mua gói Trọn đời",
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String price,
    required String unit,
    required String details,
    required Color color,
    required IconData icon,
    required IconData buttonIcon,
    required String buttonText,
    bool isBestValue = false,
    String? oldPrice,
    String? savings,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: isBestValue
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isBestValue ? 0.15 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Ưu đãi nhất",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(icon, color: Colors.white.withOpacity(0.5), size: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (oldPrice != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          oldPrice,
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            savings!,
                            style: const TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.9)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(buttonIcon, color: Colors.white, size: 20),
                      label: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, color: Color(0xFF16A34A), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Đảm bảo hoàn tiền 100%",
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Nếu không hài lòng trong 7 ngày đầu tiên, chúng tôi sẽ hoàn lại toàn bộ tiền của bạn.",
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPositive;

  const _ComparisonItem({
    required this.title,
    required this.subtitle,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
    isPositive ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final IconData icon =
    isPositive ? Icons.check_rounded : Icons.close_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}