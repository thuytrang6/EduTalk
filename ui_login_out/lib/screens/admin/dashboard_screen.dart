import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _db.collection('transactions').where('status', isEqualTo: 'success').snapshots(),
            builder: (context, transSnapshot) {
              final users = userSnapshot.data?.docs ?? [];
              final premiumUsers = users.where((u) => (u.data() as Map)['isPremium'] == true).length;

              final transactions = transSnapshot.data?.docs ?? [];
              double totalRevenue = 0;
              for (var doc in transactions) {
                totalRevenue += (doc.data() as Map)['amount'] ?? 0.0;
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    _buildHeader(users.length, premiumUsers, totalRevenue),
                    _buildMainContent(users.length, premiumUsers, transactions.length),
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildHeader(int totalUsers, int premiumUsers, double revenue) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

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
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EduTalk Business', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('Doanh thu & Chỉ số', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TỔNG DOANH THU", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                Text(currencyFormat.format(revenue), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildQuickStat("Người dùng", "$totalUsers", Icons.people_outline),
                    const SizedBox(width: 24),
                    _buildQuickStat("Premium", "$premiumUsers", Icons.star_outline),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        )
      ],
    );
  }

  Widget _buildMainContent(int users, int premium, int transCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildQuickActionSection(users, premium),
          const SizedBox(height: 16),
          _buildRecentTransactionsSection(),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return _buildContainerSection(
      title: 'Giao dịch gần đây',
      icon: Icons.history_rounded,
      iconColor: Colors.blue,
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('transactions').orderBy('timestamp', descending: true).limit(5).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("Chưa có giao dịch nào"));

          return Column(
            children: docs.map((doc) {
              final data = doc.data() as Map;
              final amount = data['amount'] ?? 0.0;
              final status = data['status'] ?? 'pending';

              return _buildTransactionItem(
                data['plan'] ?? 'Gói cước',
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount),
                status == 'success' ? Colors.green : Colors.orange,
              );
            }).toList(),
          );
        }
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickActionSection(int users, int premium) {
    return _buildContainerSection(
      title: 'Quản lý nhanh',
      icon: Icons.settings_suggest_rounded,
      iconColor: Colors.orange,
      child: Column(
        children: [
          _buildActionItem(Icons.people_alt_rounded, 'Người dùng', '$users thành viên', Colors.orange),
          _buildActionItem(Icons.workspace_premium_rounded, 'Premium', '$premium thành viên', Colors.purple),
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
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildContainerSection({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
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