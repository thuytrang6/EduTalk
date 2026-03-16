import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1e3a8a),
                    Color(0xff312e81),
                    Color(0xff0f766e),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Xin chào", style: TextStyle(color: Colors.white70)),

                  SizedBox(height: 5),

                  Text(
                    "Bạn 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  card(Icons.history, "Lịch sử", "Xem lại kết quả"),
                  const SizedBox(height: 10),
                  card(Icons.people, "Thảo luận", "Cộng đồng D30"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget card(icon, title, subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),

      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blue),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
