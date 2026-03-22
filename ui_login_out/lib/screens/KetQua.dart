import 'package:flutter/material.dart';

class KetQuaScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onRestart;
  const KetQuaScreen({super.key, required this.onBack, this.onRestart});

  @override
  State<KetQuaScreen> createState() => _KetQuaScreenState();
}

class _KetQuaScreenState extends State<KetQuaScreen> {
  bool _showAllMajors = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              buildTopSection(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const SizedBox(height: 170),
                    buildReasonCard(),
                    const SizedBox(height: 16),
                    buildChartCard(),
                    const SizedBox(height: 16),
                    buildTopMajorsCard(),
                    const SizedBox(height: 16),
                    buildUniversityCard(),
                    const SizedBox(height: 20),
                    buildRestartButton(),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //=========================HEADER SỬA Ở ĐÂY================================
  Widget buildTopSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        buildHeader(),
        Positioned(left: 14, right: 14, bottom: -170, child: buildResultCard()),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF6D28D9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onBack,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'NGÀNH PHÙ HỢP NHẤT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Công nghệ thông tin - Tin\nhọc',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.16),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFE66D),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Điểm hồ sơ:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '26.5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //======================CỤC VỊ TRÍ VIỆC LÀM ===============================
  Widget buildResultCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          buildInfoRow(
            icon: Icons.work_outline_rounded,
            iconBg: const Color(0xFFE8F0FE),
            iconColor: const Color(0xFF3B82F6),
            title: 'VỊ TRÍ VIỆC LÀM',
            content: 'Dev, AI Engineer, Data Scientist',
            contentColor: const Color(0xFF0F172A),
          ),
          buildDivider(),
          buildInfoRow(
            icon: Icons.attach_money_rounded,
            iconBg: const Color(0xFFE8F7EE),
            iconColor: const Color(0xFF16A34A),
            title: 'MỨC LƯƠNG TB',
            content: '15 - 50 triệu',
            contentColor: const Color(0xFF0EA44B),
          ),
          buildDivider(),
          buildInfoRow(
            icon: Icons.trending_up_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFFA855F7),
            title: 'XU HƯỚNG',
            content: '🔥 Rất cao',
            contentColor: const Color(0xFF9333EA),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7C8799),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: contentColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 1,
      color: const Color(0xFFE9EDF3),
    );
  }

  //=====================CỤC TẠI SAO CHỌN NGÀNH NÌ===========================
  Widget buildReasonCard() {
    final reasons = [
      'Khả năng tư duy logic và phân tích cao (4.5/5)',
      'Sự đam mê công nghệ vượt trội (5/5)',
      'Thích hợp làm việc độc lập và sáng tạo',
      'Điểm khối A00 rất phù hợp với ngành',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4ECF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFFA855F7),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Tại sao chọn ngành này?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...reasons.map(buildReasonItem),
        ],
      ),
    );
  }

  Widget buildReasonItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFDFF7E7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 15, color: Color(0xFF22C55E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF334155),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //=====================CỤC RAZDA CẦN NHUNG DATA============================
  Widget buildChartCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BIỂU ĐỒ NĂNG LỰC',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7C8799),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EEF5)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Radar Chart ở đây',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildLegendItem(
                color: const Color(0xFF3B82F6),
                label: 'Hồ sơ của bạn',
              ),
              const SizedBox(width: 18),
              buildLegendItem(
                color: const Color(0xFFEF4444),
                label: 'Yêu cầu ngành',
                isDashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDashed ? Colors.transparent : color.withOpacity(0.25),
            border: Border.all(color: color, width: 1.4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  //=====================CỤC TOP NGÀNH PHÙ HỢP===============================
  Widget buildTopMajorsCard() {
    final majors = [
      {
        'name': 'Công nghệ thông tin - Tin học',
        'score': '92%',
        'benchmark': '25.5',
        'chance': 'Cao',
        'isTop': true,
      },
      {
        'name': 'Kỹ thuật phần mềm',
        'score': '88%',
        'benchmark': '26',
        'chance': 'Trung bình',
        'isTop': false,
      },
      {
        'name': 'Trí tuệ nhân tạo',
        'score': '85%',
        'benchmark': '27.5',
        'chance': 'Trung bình',
        'isTop': false,
      },
      {
        'name': 'Công nghiệp bán dẫn',
        'score': '78%',
        'benchmark': '24.5',
        'chance': 'Cao',
        'isTop': false,
      },
      {
        'name': 'Toán tin',
        'score': '75%',
        'benchmark': '23',
        'chance': 'Cao',
        'isTop': false,
      },
    ];

    final visibleMajors = _showAllMajors ? majors : majors.take(3).toList();
    final bool canExpand = majors.length > 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.balance, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Top Ngành Phù Hợp Khác',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Column(
              children: visibleMajors.map((item) {
                final bool isTop = item['isTop'] as bool;
                final String chance = item['chance'] as String;
                final String score = item['score'] as String;

                final Color scoreColor =
                    int.parse(score.replaceAll('%', '')) >= 80
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFFF6B00);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isTop
                        ? const Color(0xFFEFFDF5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isTop
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isTop)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.emoji_events,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    item['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                children: [
                                  TextSpan(text: 'Chuẩn: ${item['benchmark']}'),
                                  const TextSpan(text: '  •  '),
                                  TextSpan(
                                    text: 'Cơ hội: $chance',
                                    style: TextStyle(
                                      color: chance == 'Cao'
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            score,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: scoreColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'ĐỘ KHỚP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          if (canExpand) ...[
            const SizedBox(height: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  setState(() {
                    _showAllMajors = !_showAllMajors;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showAllMajors ? 'Thu gọn' : 'Xem thêm',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _showAllMajors
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  //=====================CỤC TOP TRƯỜNG ĐÀO TẠO==============================
  Widget buildUniversityCard() {
    final universities = [
      {
        'name': 'ĐH Bách Khoa Hà Nội',
        'type': 'Công lập',
        'level': 'Trung bình',
        'levelColor': const Color(0xFFD18B00),
        'levelBg': const Color(0xFFF6EDB3),
        'scores': {'2023': '28.5', '2024': '28.7', '2025(DK)': '28.5+'},
        'match': 75,
      },
      {
        'name': 'ĐH Công Nghệ - ĐHQGHN',
        'type': 'Công lập',
        'level': 'Trung bình',
        'levelColor': const Color(0xFFD18B00),
        'levelBg': const Color(0xFFF6EDB3),
        'scores': {'2023': '27.8', '2024': '28', '2025(DK)': '27.5+'},
        'match': 85,
      },
      {
        'name': 'ĐH FPT',
        'type': 'Tư thục',
        'level': 'Cao',
        'levelColor': const Color(0xFF0F9F4F),
        'levelBg': const Color(0xFFDDF5E6),
        'scores': {'2023': '25', '2024': '25.5', '2025(DK)': '25.0+'},
        'match': 95,
      },
      {
        'name': 'Học viện Bưu chính Viễn thông',
        'type': 'Công lập',
        'level': 'Cao',
        'levelColor': const Color(0xFF0F9F4F),
        'levelBg': const Color(0xFFDDF5E6),
        'scores': {'2023': '26.5', '2024': '26.5', '2025(DK)': '26.5+'},
        'match': 90,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF0EA5A4),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Top Trường Đào Tạo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...universities.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final scores = item['scores'] as Map<String, String>;
            final match = item['match'] as int;

            return Container(
              padding: const EdgeInsets.only(top: 8, bottom: 14),
              decoration: BoxDecoration(
                border: index == universities.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFE9EDF3), width: 1),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF143B8F),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: item['levelBg'] as Color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item['level'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: item['levelColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// type chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item['type'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// score panel
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5EAF1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildYearScoreItem(
                            year: '2023',
                            score: scores['2023']!,
                            isHighlight: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildYearScoreItem(
                            year: '2024',
                            score: scores['2024']!,
                            isHighlight: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildYearScoreItem(
                            year: '2025(DK)',
                            score: scores['2025(DK)']!,
                            isHighlight: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// progress row
                  Row(
                    children: [
                      const Text(
                        'Độ khớp:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: match / 100,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFD7DCE5),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5B6DF6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$match%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildYearScoreItem({
    required String year,
    required String score,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFF1F5F9) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isHighlight ? Border.all(color: const Color(0xFFE2E8F0)) : null,
      ),
      child: Column(
        children: [
          Text(
            year,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isHighlight
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 15,
              fontWeight: FontWeight.w900,
              color: isHighlight
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  //=====================CỤC BUTTON PHÂN TÍCH LẠI============================
  Widget buildRestartButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFF07142D),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: widget.onRestart,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Tư vấn lại từ đầu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
