import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = [
    {'username': 'nguyenvana', 'email': 'vana@gmail.com', 'isPremium': true, 'joinDate': '2023-10-01'},
    {'username': 'tranvanb', 'email': 'vanb@gmail.com', 'isPremium': false, 'joinDate': '2023-11-15', 'trialsRemaining': 2},
    {'username': 'lethic', 'email': 'thic@gmail.com', 'isPremium': true, 'joinDate': '2024-01-20'},
    {'username': 'phamvand', 'email': 'vand@gmail.com', 'isPremium': false, 'joinDate': '2024-02-10', 'trialsRemaining': 0},
    {'username': 'hoangthie', 'email': 'thie@gmail.com', 'isPremium': false, 'joinDate': '2024-03-05', 'trialsRemaining': 3},
  ];

  String searchQuery = '';
  String filterType = 'all';

  void deleteUser(String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa người dùng "$username"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              setState(() => users.removeWhere((u) => u['username'] == username));
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void togglePremium(String username) {
    setState(() {
      final index = users.indexWhere((u) => u['username'] == username);
      if (index != -1) users[index]['isPremium'] = !users[index]['isPremium'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final matchesSearch = user['username'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesFilter = true;
      if (filterType == 'premium') matchesFilter = user['isPremium'] == true;
      if (filterType == 'free') matchesFilter = user['isPremium'] == false;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(filteredUsers.length),
          _buildSearchAndFilter(),
          Expanded(
            child: filteredUsers.isEmpty ? _buildEmptyState() : _buildUserList(filteredUsers),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quản lý người dùng',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          Text('$count người dùng', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip('all', 'Tất cả'),
              const SizedBox(width: 8),
              _buildFilterChip('premium', 'Premium'),
              const SizedBox(width: 8),
              _buildFilterChip('free', 'Miễn phí'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = filterType == type;
    return GestureDetector(
      onTap: () => setState(() => filterType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_rounded, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> filteredUsers) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user['username'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user['username'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            if (user['isPremium']) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                            ],
                          ],
                        ),
                        Text(user['email'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => togglePremium(user['username']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user['isPremium'] ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                        foregroundColor: user['isPremium'] ? const Color(0xFFB45309) : Colors.grey[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        user['isPremium'] ? 'Hủy Premium' : 'Cấp Premium',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => deleteUser(user['username']),
                    icon: const Icon(Icons.delete_outline_rounded, size: 15),
                    label: const Text('Xóa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}