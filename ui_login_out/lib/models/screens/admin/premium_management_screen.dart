import 'package:flutter/material.dart';

class PremiumManagementScreen extends StatefulWidget {
  const PremiumManagementScreen({super.key});

  @override
  State<PremiumManagementScreen> createState() => _PremiumManagementScreenState();
}

class _PremiumManagementScreenState extends State<PremiumManagementScreen> {
  List<Map<String, dynamic>> premiumUsers = [
    {'username': 'nguyenvana', 'email': 'vana@gmail.com', 'premiumSince': '2023-10-01', 'revenue': 199000},
    {'username': 'lethic', 'email': 'thic@gmail.com', 'premiumSince': '2024-01-20', 'revenue': 199000},
    {'username': 'hoangminh', 'email': 'minh@gmail.com', 'premiumSince': '2024-02-15', 'revenue': 199000},
    {'username': 'thuytien', 'email': 'tien@gmail.com', 'premiumSince': '2024-03-01', 'revenue': 199000},
  ];

  String searchQuery = '';

  String formatCurrency(num amount) {
    String str = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }
    return '$result ₫';
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = premiumUsers
        .where((user) => user['username'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    final totalRevenue = premiumUsers.length * 199000;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(premiumUsers.length, totalRevenue),
            _buildSearchBox(),
            const SizedBox(height: 8),
            _buildRevenueStats(totalRevenue),
            const SizedBox(height: 16),
            _buildPremiumList(filteredUsers),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count, int revenue) {
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
          const Text('Quản lý Premium',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildHeaderCard(Icons.workspace_premium_rounded, Colors.amber, 'Thành viên', '$count')),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderCard(
                  Icons.monetization_on_rounded,
                  Colors.greenAccent,
                  'Doanh thu',
                  '${(revenue / 1000000).toStringAsFixed(1)}M',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(IconData icon, Color iconColor, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.orange[100], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: (val) => setState(() => searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm thành viên Premium...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRevenueStats(int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Thống kê doanh thu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber[50]!, Colors.orange[50]!]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber[100]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng doanh thu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                Text(formatCurrency(total),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF7A3300))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Gói Premium', formatCurrency(199000)),
          _buildDetailRow('TB/người dùng', formatCurrency(199000)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPremiumList(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.workspace_premium_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Chưa có thành viên Premium', style: TextStyle(color: Colors.grey[500])),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFB8C00)]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Text(
                    user['username'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 14),
                      ],
                    ),
                    Text(user['email'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text('Premium từ: ${user['premiumSince']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Đóng góp', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(formatCurrency(user['revenue']),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}