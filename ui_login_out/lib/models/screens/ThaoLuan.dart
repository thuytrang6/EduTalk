import 'package:flutter/material.dart';

class ThaoLuanScreen extends StatefulWidget {
  const ThaoLuanScreen({super.key});

  @override
  State<ThaoLuanScreen> createState() => _ThaoLuanScreenState();
}

class _ThaoLuanScreenState extends State<ThaoLuanScreen> {
  bool likedPost1 = false;
  int likesPost1 = 18;

  bool likedPost2 = true;
  int likesPost2 = 31;

  String activeTab = "Mới nhất";

  void toggleLikePost1() {
    setState(() {
      likedPost1 = !likedPost1;
      likesPost1 += likedPost1 ? 1 : -1;
    });
  }

  void toggleLikePost2() {
    setState(() {
      likedPost2 = !likedPost2;
      likesPost2 += likedPost2 ? 1 : -1;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _TopSection(
                activeTab: activeTab,
                onTabChanged: changeTab,
              ),
              const SizedBox(height: 18),
              _ComposerSection(
                onTap: openCreatePostSheet,
              ),
              const SizedBox(height: 18),
              _PostCard(
                avatarText: "N",
                author: "Nguyễn Xuân Định",
                meta: "2k6 • Khối A00 • 2 giờ trước",
                topic: "Tư vấn ngành",
                topicBg: const Color(0xFFEAF1FF),
                topicText: const Color(0xFF2563EB),
                topicBorder: const Color(0xFFD1DDF8),
                content:
                    "Mọi người cho mình hỏi, được 26 điểm khối A00 thì có cơ hội đỗ Khoa học Máy tính Bách Khoa năm nay không ạ? Mình đang khá lo và chưa biết nên đặt NV thế nào cho hợp lý.",
                likes: likesPost1.toString(),
                comments: "7",
                liked: likedPost1,
                onLike: toggleLikePost1,
              ),
              const SizedBox(height: 18),
              _PostCard(
                avatarText: "T",
                author: "Nguyễn Thị Thùy Trang",
                meta: "Quan tâm Marketing • 5 giờ trước",
                topic: "Review ngành học",
                topicBg: const Color(0xFFF1EBFF),
                topicText: const Color(0xFF7C3AED),
                topicBorder: const Color(0xFFDED2FF),
                content:
                    "Mình vừa dùng hệ thống AI gợi ý ngành và được đề xuất Marketing số. Có anh chị nào đang học hoặc làm ngành này cho mình xin review thực tế với ạ, nhất là cơ hội việc làm sau tốt nghiệp.",
                likes: likesPost2.toString(),
                comments: "12",
                liked: likedPost2,
                onLike: toggleLikePost2,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const _TopSection({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD9DEE7),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
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
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleButton(icon: Icons.search_rounded),
              SizedBox(width: 10),
              Stack(
                children: [
                  _CircleButton(icon: Icons.notifications_none_rounded),
                  Positioned(
                    right: 10,
                    top: 9,
                    child: _Dot(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _IntroCard(),
          const SizedBox(height: 20),
          _ForumTabBar(
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
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
        border: Border.all(
          color: const Color(0xFFD4DAE4),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 24,
        color: const Color(0xFF5D6880),
      ),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD5DAE3),
          width: 1,
        ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
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
                    height: 1.28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Tư vấn ngành học, review trường, chia sẻ kinh nghiệm\nôn thi và kết nối với cộng đồng phù hợp.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF70809B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFE7EAEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 24,
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

  const _ForumTabBar({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Mới nhất", "Nổi bật", "Theo dõi"];

    return Row(
      children: tabs
          .map(
            (tab) => Padding(
              padding: EdgeInsets.only(right: tab == tabs.last ? 0 : 12),
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

  const _ComposerSection({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFD5DAE3),
            width: 1,
          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAECEF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Đặt câu hỏi hoặc chia sẻ điều bạn đang quan\ntâm...",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.45,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
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
  final Color bg;
  final Color text;
  final Color border;

  const _TopicChip({
    required this.title,
    required this.bg,
    required this.text,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
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
  final String avatarText;
  final String author;
  final String meta;
  final String topic;
  final Color topicBg;
  final Color topicText;
  final Color topicBorder;
  final String content;
  final String likes;
  final String comments;
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
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFD5DAE3),
            width: 1,
          ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              meta,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: topicBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: topicBorder),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: liked
                              ? const Color(0xFFF43F5E)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        likes,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: liked
                              ? const Color(0xFFF43F5E)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.mode_comment_outlined,
                        size: 22,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comments,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.share_outlined,
                        size: 22,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Chia sẻ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
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

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController controller = TextEditingController();
  String selectedTopic = "Tư vấn ngành";

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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(34),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
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
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
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
                          size: 24,
                          color: Color(0xFF68748C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: const [
                    _SheetUserAvatar(),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "1",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Hãy viết điều hữu ích cho cộng đồng",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SelectableTopicChip(
                        title: "Tư vấn ngành",
                        selected: selectedTopic == "Tư vấn ngành",
                        onTap: () {
                          setState(() {
                            selectedTopic = "Tư vấn ngành";
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _SelectableTopicChip(
                        title: "Review ngành học",
                        selected: selectedTopic == "Review ngành học",
                        onTap: () {
                          setState(() {
                            selectedTopic = "Review ngành học";
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _SelectableTopicChip(
                        title: "Kinh nghiệm ôn thi",
                        selected: selectedTopic == "Kinh nghiệm ôn thi",
                        onTap: () {
                          setState(() {
                            selectedTopic = "Kinh nghiệm ôn thi";
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAECEF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFD5DAE3),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 7,
                    maxLength: 500,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText:
                          "Ví dụ: Mình đang phân vân giữa Công nghệ thông tin và Marketing số, mọi người cho mình xin góc nhìn thực tế với...",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Color(0xFF9AA6B8),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      "$count/500 ký tự",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8DEE8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            "Đăng bài",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A99B2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.send_outlined,
                            size: 18,
                            color: Color(0xFF8A99B2),
                          ),
                        ],
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
      child: const Text(
        "1",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                selected ? const Color(0xFF0F172A) : const Color(0xFFD5DAE3),
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