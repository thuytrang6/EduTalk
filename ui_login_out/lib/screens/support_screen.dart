import 'package:flutter/material.dart';
import 'support_request_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),

      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        centerTitle: true,

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Liên hệ hỗ trợ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          // ==================================================
          // TOP BACKGROUND
          // ==================================================
          Container(
            height: 230,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  Color(0xff1e3a8a),
                  Color(0xff312e81),
                  Color(0xff0f766e),
                ],
              ),

              borderRadius: BorderRadius.vertical(bottom: Radius.circular(42)),
            ),
          ),

          // ==================================================
          // CONTENT
          // ==================================================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 120, 20, 30),

            child: Column(
              children: [
                // ==============================================
                // HEADER CARD
                // ==============================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,

                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff06b6d4), Color(0xff14b8a6)],
                          ),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Chúng tôi luôn sẵn sàng hỗ trợ",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1e293b),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Liên hệ với đội ngũ hỗ trợ nếu bạn gặp bất kỳ vấn đề nào trong quá trình sử dụng ứng dụng.",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 14,
                          height: 1.8,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==============================================
                // CONTACT ITEMS
                // ==============================================
                _buildContactItem(
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xff2563eb),
                  bgColor: const Color(0xffeff6ff),

                  title: "Email hỗ trợ",
                  subtitle: "support@edutalk.ai",
                ),

                _buildContactItem(
                  icon: Icons.phone_outlined,
                  iconColor: const Color(0xff059669),
                  bgColor: const Color(0xffecfdf5),

                  title: "Hotline",
                  subtitle: "1900 6067",
                ),

                const SizedBox(height: 24),

                // ==============================================
                // BUTTON
                // ==============================================
                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportRequestScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1e293b),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: const Text(
                      "Gửi yêu cầu hỗ trợ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1e293b),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
