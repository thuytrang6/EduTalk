import 'package:flutter/material.dart';

// 1. Model dữ liệu (Bạn có thể chuyển class này ra file riêng trong thư mục lib/models sau này)
class ConsultationResult {
  final int id;
  final String date;
  final String major;
  final double score;
  final List<String> schools;

  ConsultationResult({
    required this.id,
    required this.date,
    required this.major,
    required this.score,
    required this.schools,
  });
}

class LichSuScreen extends StatelessWidget {
  const LichSuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu tạm thời để build UI.
    // Sau này khi ráp code với team, bạn sẽ lấy data này từ DB hoặc State Management.
    final List<ConsultationResult> historyData = [
      ConsultationResult(
        id: 3,
        date: '15/5/2024 8:30',
        major: 'Công nghệ thông tin - Tin học',
        score: 26.5,
        schools: ['ĐH Bách Khoa', 'ĐH Công Nghệ', 'ĐH FPT'],
      ),
      ConsultationResult(
        id: 2,
        date: '12/5/2024 14:20',
        major: 'Kinh tế - Quản trị kinh doanh',
        score: 25.0,
        schools: ['ĐH Kinh tế Quốc dân', 'ĐH Ngoại thương'],
      ),
      ConsultationResult(
        id: 1,
        date: '10/5/2024 9:15',
        major: 'Truyền thông đa phương tiện',
        score: 24.0,
        schools: ['Học viện Báo chí', 'ĐH KHXH&NV'],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 40, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B3B86), Color(0xFF381B85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.access_time_filled, color: Colors.yellowAccent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Lịch Sử Tư Vấn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    children: [
                      TextSpan(text: 'Hồ sơ của tài khoản: '),
                      TextSpan(
                        text: 'phuongnhi', // Sau này thay bằng biến tên user
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách các thẻ Lịch sử
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 100),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                return HistoryCard(data: historyData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Widget Card hiển thị từng mục (Tách riêng để code dễ đọc)
class HistoryCard extends StatelessWidget {
  final ConsultationResult data;

  const HistoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF4A65FF),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LẦN TƯ VẤN #${data.id}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data.date,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.major,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ĐIỂM HỒ SƠ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.score.toString().replaceAll('.0', ''),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOP TRƯỜNG ĐỀ XUẤT',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: data.schools.map((school) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    school,
                                    style: const TextStyle(
                                      color: Color(0xFF4A65FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}