import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ui_login_out/services/post_service.dart';
import 'package:ui_login_out/models/post_model.dart';

class ThaoLuanScreen extends StatefulWidget {
  const ThaoLuanScreen({super.key});

  @override
  State<ThaoLuanScreen> createState() => _ThaoLuanScreenState();
}

class _ThaoLuanScreenState extends State<ThaoLuanScreen> {
  String activeTab = "Mới nhất";

  void changeTab(String tab) {
    setState(() {
      activeTab = tab;
    });
  }

  void openCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreatePostSheet(),
    );
  }

  Stream<List<PostModel>> _getPostsStream() {
    final service = PostService();
    return service.getPostsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _TopSection(activeTab: activeTab, onTabChanged: changeTab),
              const SizedBox(height: 18),
              _ComposerSection(onTap: openCreatePostSheet),
              const SizedBox(height: 18),

              StreamBuilder<List<PostModel>>(
                stream: _getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Đã xảy ra lỗi: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          "Chưa có thảo luận nào. Hãy đăng bài đầu tiên!",
                        ),
                      ),
                    );
                  }

                  final posts = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      Color topicColor = const Color(0xFF2563EB);
                      Color topicBg = const Color(0xFFEAF1FF);
                      if (post.tag == "Review ngành học") {
                        topicColor = const Color(0xFF7C3AED);
                        topicBg = const Color(0xFFF1EBFF);
                      } else if (post.tag == "Kinh nghiệm ôn thi") {
                        topicColor = const Color(0xFF0F8A5F);
                        topicBg = const Color(0xFFEAF8EF);
                      }

                      return Column(
                        children: [
                          _PostCard(
                            avatarText: post.authorName.isNotEmpty
                                ? post.authorName[0].toUpperCase()
                                : "?",
                            author: post.authorName,
                            meta: "${post.authorBio} • Vừa xong",
                            topic: post.tag,
                            topicBg: topicBg,
                            topicText: topicColor,
                            topicBorder: topicColor.withOpacity(0.2),
                            content: post.content,
                            likes: post.interactionCount.toString(),
                            comments: "0",
                            onLike: () {
                              // Gọi hàm like từ PostService
                            },
                          ),
                          const SizedBox(height: 18),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SHEET TẠO BÀI VIẾT (ĐÃ FIX UI & NÚT BẤM)
// ===========================================================================
class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController controller = TextEditingController();
  String selectedTopic = "Tư vấn ngành";
  String selectedBlock = "A00";
  bool _isLoading = false;

  final List<String> examBlocks = ["A00", "A01", "B00", "C00", "D01"];

  String calculateYearTag(Timestamp? dob) {
    if (dob == null) return "2k?";
    final year = dob.toDate().year;
    return "2k${year.toString().substring(2)}";
  }

  Future<void> _handlePostSubmit() async {
    final content = controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Bạn cần đăng nhập!");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String realName = "Người dùng EduTalk";
      String yearTag = "2k?";

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        realName = userData['hoTen'] ?? "Người dùng";
        yearTag = calculateYearTag(userData['ngaySinh'] as Timestamp?);
      }

      final String finalBio = "$yearTag • Khối $selectedBlock";

      final postService = PostService();
      final newPost = PostModel(
        content: content,
        tag: selectedTopic,
        authorName: realName,
        authorBio: finalBio,
        createdAt: DateTime.now(),
        interactionCount: 0,
      );

      await postService.createPost(newPost);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã chia sẻ bài viết thành công!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${e.toString().replaceAll("Exception: ", "")}"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = controller.text.length;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CREATE POST",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tạo bài viết mới",
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF182033),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE7EAEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF68748C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // FIX 1: KHỐI HỌC BẮT MẮT HƠN
                const Text(
                  "Khối học của bạn",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: examBlocks.map((block) {
                    bool isSelected = selectedBlock == block;
                    return ChoiceChip(
                      label: Text(block),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => selectedBlock = block),
                      selectedColor: const Color(0xFF0F172A),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Chọn chủ đề",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                              "Tư vấn ngành",
                              "Review ngành học",
                              "Kinh nghiệm ôn thi",
                            ]
                            .map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _SelectableTopicChip(
                                  title: tag,
                                  selected: selectedTopic == tag,
                                  onTap: () =>
                                      setState(() => selectedTopic = tag),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 22),

                // FIX 2: CHỮ ĐEN TRONG Ô NHẬP NỘI DUNG
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAECEF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFD5DAE3)),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 6,
                    maxLength: 500,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ), // Màu đen
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: "Chia sẻ thắc mắc của bạn tại đây...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // FIX 3: NÚT ĐĂNG BÀI - TỐI ƯU TRẠNG THÁI
                Row(
                  children: [
                    Text(
                      "$count/500 ký tự",
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: (_isLoading || count == 0)
                          ? null
                          : _handlePostSubmit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: count > 0
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: count > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                children: [
                                  Text(
                                    "Đăng bài",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: count > 0
                                          ? Colors.white
                                          : const Color(0xFF8A99B2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.send_rounded,
                                    size: 18,
                                    color: count > 0
                                        ? Colors.white
                                        : const Color(0xFF8A99B2),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CÁC WIDGET GIAO DIỆN (GIỮ NGUYÊN) ---

class _TopSection extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  const _TopSection({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD9DEE7), width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "COMMUNITY",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Cộng đồng thảo luận",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF182033),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleButton(icon: Icons.search_rounded),
              const SizedBox(width: 10),
              Stack(
                children: [
                  _CircleButton(icon: Icons.notifications_none_rounded),
                  const Positioned(right: 10, top: 9, child: _Dot()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _IntroCard(),
          const SizedBox(height: 20),
          _ForumTabBar(activeTab: activeTab, onTabChanged: onTabChanged),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  const _CircleButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4DAE4)),
      ),
      child: Icon(icon, size: 24, color: const Color(0xFF5D6880)),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFFF43F5E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD5DAE3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EEF9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 16,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Hỏi đáp đúng mối quan tâm",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Nơi học sinh hỏi thật,\nngười đi trước trả lời thật",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Tư vấn và chia sẻ cùng cộng đồng EduTalk.",
                  style: TextStyle(fontSize: 15, color: Color(0xFF70809B)),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFE7EAEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF68748C),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumTabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  const _ForumTabBar({required this.activeTab, required this.onTabChanged});
  @override
  Widget build(BuildContext context) {
    final tabs = ["Mới nhất", "Nổi bật", "Theo dõi"];
    return Row(
      children: tabs
          .map(
            (tab) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => onTabChanged(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: activeTab == tab
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE7EAEE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: activeTab == tab
                          ? Colors.white
                          : const Color(0xFF5F6C83),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ComposerSection extends StatelessWidget {
  final VoidCallback onTap;
  const _ComposerSection({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD5DAE3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1636),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "1",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAECEF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Bạn đang thắc mắc điều gì?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TopicChip(
                    title: "Tư vấn ngành",
                    bg: Color(0xFFEAF1FF),
                    text: Color(0xFF2563EB),
                    border: Color(0xFFD1DDF8),
                  ),
                  SizedBox(width: 10),
                  _TopicChip(
                    title: "Review ngành học",
                    bg: Color(0xFFF1EBFF),
                    text: Color(0xFF7C3AED),
                    border: Color(0xFFDED2FF),
                  ),
                  SizedBox(width: 10),
                  _TopicChip(
                    title: "Kinh nghiệm ôn thi",
                    bg: Color(0xFFEAF8EF),
                    text: Color(0xFF0F8A5F),
                    border: Color(0xFFCDEAD9),
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

class _TopicChip extends StatelessWidget {
  final String title;
  final Color bg, text, border;
  const _TopicChip({
    required this.title,
    required this.bg,
    required this.text,
    required this.border,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String avatarText, author, meta, topic;
  final Color topicBg, topicText, topicBorder;
  final String content, likes, comments;
  final bool liked;
  final VoidCallback onLike;
  const _PostCard({
    required this.avatarText,
    required this.author,
    required this.meta,
    required this.topic,
    required this.topicBg,
    required this.topicText,
    required this.topicBorder,
    required this.content,
    required this.likes,
    required this.comments,
    required this.onLike,
    this.liked = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD5DAE3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EAEE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                avatarText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF32415A),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              meta,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: topicBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: topicBorder),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: topicText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(height: 1, color: const Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: liked ? Colors.red : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        likes,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.mode_comment_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comments,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Chia sẻ",
                        style: TextStyle(fontWeight: FontWeight.bold),
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

class _SheetUserAvatar extends StatelessWidget {
  const _SheetUserAvatar();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1636),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}

class _SelectableTopicChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableTopicChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF0F172A) : const Color(0xFFD5DAE3),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
