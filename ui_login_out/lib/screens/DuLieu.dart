import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Premium_screen.dart';

class DuLieuScreen extends StatefulWidget {
  final ValueChanged<int>? onChangeTab;
  final VoidCallback? onOPenPhanTich;
  const DuLieuScreen({super.key, this.onChangeTab, this.onOPenPhanTich});

  @override
  State<DuLieuScreen> createState() => DuLieuScreenState();
}

class DuLieuScreenState extends State<DuLieuScreen> {
  String region = "Cả nước";
  String group = "A00";

  final Map<String, List<String>> subjectsMap = {
    "A00": ["Toán", "Lý", "Hóa"],
    "A01": ["Toán", "Lý", "Anh"],
    "B00": ["Toán", "Hóa", "Sinh"],
    "C00": ["Văn", "Sử", "Địa"],
    "D01": ["Toán", "Văn", "Anh"],
  };

  final Map<String, String> groupTitleMap = {
    "A00": "A00 - Toán, Lý, Hóa",
    "A01": "A01 - Toán, Lý, Anh",
    "B00": "B00 - Toán, Hóa, Sinh",
    "C00": "C00 - Văn, Sử, Địa",
    "D01": "D01 - Toán, Văn, Anh",
  };

  List<String> subjects = ["Toán", "Lý", "Hóa"];

  final List<TextEditingController> scores = [
    TextEditingController(text: "0.0"),
    TextEditingController(text: "0.0"),
    TextEditingController(text: "0.0"),
  ];

  void changeGroup(String value) {
    setState(() {
      group = value;
      subjects = subjectsMap[value]!;
    });
  }

  void _changeScore(int index, double delta) {
    final current =
        double.tryParse(scores[index].text.replaceAll(',', '.')) ?? 0.0;
    final next = (current + delta).clamp(0.0, 10.0);
    scores[index].text = next.toStringAsFixed(1);
    setState(() {});
  }

  void _normalizeScore(int index) {
    final value =
        double.tryParse(scores[index].text.replaceAll(',', '.')) ?? 0.0;
    final normalized = value.clamp(0.0, 10.0);
    scores[index].text = normalized.toStringAsFixed(1);
    setState(() {});
  }

  void handleOpenPhanTich() {
    widget.onOPenPhanTich?.call();
  }

  void resetForm() {
    setState(() {
      region = "Cả nước";
      group = "A00";
      subjects = subjectsMap[group]!;
      for (var controller in scores) {
        controller.text = "0.0";
      }
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    for (final controller in scores) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 740,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildHeader(),
                    Positioned(
                      top: 300,
                      left: 20,
                      right: 20,
                      child: _buildFormCard(),
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 3),
              _buildAnalyzeButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 370,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1e3a8a), Color(0xff312e81), Color(0xff0f766e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          const SizedBox(height: 34),
          const Text(
            "Hồ Sơ Học Tập",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Nhập điểm tổ hợp môn bạn muốn xét",
            style: TextStyle(fontSize: 15, height: 1.4, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          _buildTrialCard(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 11,
                backgroundColor: Color(0x1A22D3EE),
                child: Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Color.fromARGB(255, 34, 235, 238),
                ),
              ),
              SizedBox(width: 8),
              Text(
                "Name",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xff1d4ed8).withOpacity(.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color.fromARGB(60, 7, 7, 255)),
          ),
          child: const Text(
            "Bước 1/2",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  //Thêm chuyển trang Nâng Cấp ở đây nè
  Widget _buildTrialCard() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 211, 121, 3).withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 223, 146, 30).withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Còn 3/3 lượt dùng thử",
              style: TextStyle(
                color: Color(0xffffe08a),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffffb82e), Color(0xffff991f)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "Nâng cấp",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Khu vực ưu tiên",
            textColor: Colors.black,
            bgColor: const Color.fromARGB(199, 255, 255, 255),
          ),
          const SizedBox(height: 12),
          _buildRegionDropdown(),
          const SizedBox(height: 24),
          _buildSectionTitle(
            "Tổ hợp môn",
            textColor: const Color.fromARGB(255, 6, 19, 40),
          ),
          const SizedBox(height: 12),
          _buildGroupDropdown(),
          const SizedBox(height: 28),
          _buildScoreRow(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    Color textColor = const Color(0xff374151),
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      value: region,
      isExpanded: true,
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          region = value;
        });
      },

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xff9ca3af),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xffd6dbe7), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xff3b82f6), width: 1.8),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      items: const [
        DropdownMenuItem(value: "Cả nước", child: Text("Cả nước")),
        DropdownMenuItem(value: "Miền Bắc", child: Text("Miền Bắc")),
        DropdownMenuItem(value: "Miền Trung", child: Text("Miền Trung")),
        DropdownMenuItem(value: "Miền Nam", child: Text("Miền Nam")),
      ],
    );
  }

  Widget _buildGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: group,
      onChanged: (value) {
        if (value == null) return;
        changeGroup(value);
      },
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xff2563eb),
      ),
      decoration: _dropdownDecoration(
        fillColor: const Color(0xffeef4ff),
        borderColor: const Color(0xffbfdbfe),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
      style: const TextStyle(
        color: Color(0xff1e40af),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      selectedItemBuilder: (context) {
        return groupTitleMap.entries.map((entry) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff1e40af),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList();
      },
      items: groupTitleMap.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
    );
  }

  InputDecoration _dropdownDecoration({
    required Color fillColor,
    required Color borderColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: borderColor, width: 1.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      children: List.generate(subjects.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == subjects.length - 1 ? 0 : 12,
            ),
            child: _buildScoreCard(
              label: subjects[index].toUpperCase(),
              controller: scores[index],
              index: index,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScoreCard({
    required String label,
    required TextEditingController controller,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffeef2f7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xff1d4ed8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xffe5e7eb)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    onFieldSubmitted: (_) => _normalizeScore(index),
                    onEditingComplete: () => _normalizeScore(index),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff6b7280),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  margin: const EdgeInsets.only(right: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _changeScore(index, 0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(1),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 18,
                            color: Color(0xff9ca3af),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _changeScore(index, -0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(1),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xff9ca3af),
                          ),
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

  Widget _buildAnalyzeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            widget.onOPenPhanTich?.call();
          },
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: const Color(0x332563eb),
            backgroundColor: const Color(0xff2563eb),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Phân tích AI",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
