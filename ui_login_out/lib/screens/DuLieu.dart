import 'package:flutter/material.dart';

class DuLieuScreen extends StatefulWidget {
  const DuLieuScreen({super.key});

  @override
  State<DuLieuScreen> createState() => _DuLieuScreenState();
}

class _DuLieuScreenState extends State<DuLieuScreen> {
  String region = "Cả nước";
  String group = "A00";

  Map<String, List<String>> subjectsMap = {
    "A00": ["Toán", "Lý", "Hóa"],
    "A01": ["Toán", "Lý", "Anh"],
    "B00": ["Toán", "Hóa", "Sinh"],
    "C00": ["Văn", "Sử", "Địa"],
    "D01": ["Toán", "Văn", "Anh"],
  };

  List<String> subjects = ["Toán", "Lý", "Hóa"];

  final List<TextEditingController> scores = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void changeGroup(String value) {
    setState(() {
      group = value;
      subjects = subjectsMap[value]!;
      for (var c in scores) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1e3a8a), Color(0xff2563eb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hồ Sơ Học Tập",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Nhập điểm dự kiến để AI phân tích",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            /// CARD
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Container(
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 25,
                        color: Colors.black12,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// REGION
                      const Text(
                        "Khu vực ưu tiên",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        value: region,
                        items: const [
                          DropdownMenuItem(
                            value: "Cả nước",
                            child: Text("Cả nước"),
                          ),
                          DropdownMenuItem(
                            value: "Miền Bắc",
                            child: Text("Miền Bắc"),
                          ),
                          DropdownMenuItem(
                            value: "Miền Trung",
                            child: Text("Miền Trung"),
                          ),
                          DropdownMenuItem(
                            value: "Miền Nam",
                            child: Text("Miền Nam"),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            region = v!;
                          });
                        },

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xfff3f4f6),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// GROUP
                      const Text(
                        "Tổ hợp môn",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        value: group,
                        items: const [
                          DropdownMenuItem(
                            value: "A00",
                            child: Text("A00 - Toán Lý Hóa"),
                          ),
                          DropdownMenuItem(
                            value: "A01",
                            child: Text("A01 - Toán Lý Anh"),
                          ),
                          DropdownMenuItem(
                            value: "B00",
                            child: Text("B00 - Toán Hóa Sinh"),
                          ),
                          DropdownMenuItem(
                            value: "C00",
                            child: Text("C00 - Văn Sử Địa"),
                          ),
                          DropdownMenuItem(
                            value: "D01",
                            child: Text("D01 - Toán Văn Anh"),
                          ),
                        ],
                        onChanged: (v) {
                          changeGroup(v!);
                        },

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffeef2ff),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// SCORES
                      Row(
                        children: List.generate(subjects.length, (i) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: const Color(0xfff9fafb),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xfff1f5f9),
                                ),
                              ),

                              child: Column(
                                children: [
                                  Text(
                                    subjects[i],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff1e3a8a),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  TextField(
                                    controller: scores[i],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,

                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),

                                    decoration: InputDecoration(
                                      hintText: "0.0",
                                      filled: true,
                                      fillColor: Colors.white,

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 35),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: const Color(0xff2563eb),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                            elevation: 6,
                          ),

                          onPressed: () {},

                          child: const Text(
                            "Tiếp theo",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
