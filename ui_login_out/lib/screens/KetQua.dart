import 'package:flutter/material.dart';

class KetQuaScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onRestart;
  final String predictedMajor;
  final List<dynamic> recommendations;
  final List<int> userScores;
  final List<int> majorRequirements;
  final double totalScore; // ← tổng điểm từ DuLieu

  const KetQuaScreen({
    super.key,
    required this.onBack,
    this.onRestart,
    required this.predictedMajor,
    required this.recommendations,
    required this.userScores,
    required this.majorRequirements,
    required this.totalScore,
  });

  @override
  State<KetQuaScreen> createState() => _KetQuaScreenState();
}

class _KetQuaScreenState extends State<KetQuaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                Text(
                  widget.predictedMajor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // ← Hiển thị tổng điểm thay vì "Kết quả AI"
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
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Color(0xFFFFE66D),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Điểm của bạn: ${widget.totalScore.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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

  Widget buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(10),
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
            content: 'Tùy ngành được gợi ý',
            contentColor: const Color(0xFF0F172A),
          ),
          buildDivider(),
          buildInfoRow(
            icon: Icons.attach_money_rounded,
            iconBg: const Color(0xFFE8F7EE),
            iconColor: const Color(0xFF16A34A),
            title: 'MỨC LƯƠNG TB',
            content: 'Tham khảo thêm',
            contentColor: const Color(0xFF0EA44B),
          ),
          buildDivider(),
          buildInfoRow(
            icon: Icons.trending_up_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFFA855F7),
            title: 'XU HƯỚNG',
            content: '🔥 Đang tăng',
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
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
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C8799),
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

  Widget buildReasonCard() {
    final reasons = [
      'Dựa trên 10 chỉ số sở thích của bạn',
      'Mô hình AI phân tích và gợi ý ngành phù hợp nhất',
      'Kết quả được lưu vào lịch sử của bạn',
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

  Widget buildChartCard() {
    final labels = [
      'Năng động',
      'Hướng nội',
      'Sáng tạo',
      'Logic',
      'Tò mò',
      'Cảm thông',
      'Công nghệ',
      'Xã hội',
      'Sức khỏe',
      'Nghệ thuật',
    ];
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
          // Radar chart placeholder — sẽ thêm fl_chart sau
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EEF5)),
            ),
            alignment: Alignment.center,
            child: widget.userScores.isEmpty
                ? const Text(
                    'Chưa có dữ liệu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  )
                : CustomPaint(
                    size: const Size(240, 240),
                    painter: _RadarChartPainter(
                      userScores: widget.userScores
                          .map((e) => e.toDouble())
                          .toList(),
                      majorRequirements: widget.majorRequirements
                          .map((e) => e.toDouble())
                          .toList(),
                      labels: labels,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: const Color(0xFF3B82F6),
                label: 'Hồ sơ của bạn',
              ),
              const SizedBox(width: 18),
              _buildLegendItem(
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

  Widget _buildLegendItem({
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

  Widget buildUniversityCard() {
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
              Icon(Icons.school_rounded, color: Color(0xFF0EA5A4), size: 20),
              SizedBox(width: 8),
              Text(
                'Top Trường Gợi Ý',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (widget.recommendations.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Không có trường nào được gợi ý',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ...widget.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final uni = entry.value as Map<String, dynamic>;
              final isLast = index == widget.recommendations.length - 1;
              return Container(
                padding: const EdgeInsets.only(top: 8, bottom: 14),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(
                            color: Color(0xFFE9EDF3),
                            width: 1,
                          ),
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uni['ten_truong']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF143B8F),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            uni['ten_nganh']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7EE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Điểm chuẩn 2024: ${uni['diem_chuan_2024'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          if (uni['website'] != null &&
                              uni['website'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              uni['website'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

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

// ── RADAR CHART PAINTER ────────────────────────────────────────────────────────
class _RadarChartPainter extends CustomPainter {
  final List<double> userScores;
  final List<double> majorRequirements;
  final List<String> labels;

  _RadarChartPainter({
    required this.userScores,
    required this.majorRequirements,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int n = labels.length;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;
    const maxVal = 5.0;

    // Vẽ lưới nền
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int level = 1; level <= 5; level++) {
      final r = radius * level / maxVal;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = (i * 2 * 3.141592653589793 / n) - 3.141592653589793 / 2;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Vẽ trục
    final axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1;
    for (int i = 0; i < n; i++) {
      final angle = (i * 2 * 3.141592653589793 / n) - 3.141592653589793 / 2;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        axisPaint,
      );
    }

    // Vẽ vùng yêu cầu ngành (đỏ, nét đứt)
    if (majorRequirements.length == n) {
      final majorPath = Path();
      for (int i = 0; i < n; i++) {
        final angle = (i * 2 * 3.141592653589793 / n) - 3.141592653589793 / 2;
        final r = radius * (majorRequirements[i] / maxVal);
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0)
          majorPath.moveTo(x, y);
        else
          majorPath.lineTo(x, y);
      }
      majorPath.close();
      canvas.drawPath(
        majorPath,
        Paint()
          ..color = const Color(0x22EF4444)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        majorPath,
        Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Vẽ vùng người dùng (xanh)
    if (userScores.length == n) {
      final userPath = Path();
      for (int i = 0; i < n; i++) {
        final angle = (i * 2 * 3.141592653589793 / n) - 3.141592653589793 / 2;
        final r = radius * (userScores[i] / maxVal);
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0)
          userPath.moveTo(x, y);
        else
          userPath.lineTo(x, y);
      }
      userPath.close();
      canvas.drawPath(
        userPath,
        Paint()
          ..color = const Color(0x443B82F6)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        userPath,
        Paint()
          ..color = const Color(0xFF3B82F6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Chấm tròn tại các đỉnh
      final dotPaint = Paint()
        ..color = const Color(0xFF3B82F6)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < n; i++) {
        final angle = (i * 2 * 3.141592653589793 / n) - 3.141592653589793 / 2;
        final r = radius * (userScores[i] / maxVal);
        canvas.drawCircle(
          Offset(center.dx + r * cos(angle), center.dy + r * sin(angle)),
          4,
          dotPaint,
        );
      }
    }

    // Vẽ nhãn
    final textStyle = const TextStyle(
      color: Color(0xFF475569),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );
    for (int i = 0; i < n; i++) {
      final angle = (i * 2 * 3.141592653589793 / n) - 3.141592653589793 / 2;
      final labelR = radius + 18;
      final x = center.dx + labelR * cos(angle);
      final y = center.dy + labelR * sin(angle);
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 60);
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  double cos(double angle) => (angle == 0) ? 1 : _cos(angle);
  double sin(double angle) => (angle == 0) ? 0 : _sin(angle);

  double _cos(double x) {
    double result = 1, term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sin(double x) {
    double result = x, term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
