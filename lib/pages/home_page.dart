// home_page.dart
import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/profile_page.dart';
import 'package:pe_emoease_mobileapp_flutter/services/profile_service.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/dashboard_page.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final purple = Colors.deepPurple;
  final PageController _bannerController = PageController(viewportFraction: 0.9);
  int _bannerIndex = 0;
  int _navIndex = 0;
  final _profileService = ProfileService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bannerController.addListener(() {
      final idx = _bannerController.page?.round() ?? 0;
      if (_bannerIndex != idx) setState(() => _bannerIndex = idx);
    });
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.fetchPatientProfile();
      final profileDto = data['patientProfileDto'] as Map<String, dynamic>;
      setState(() {
        _profile = profileDto;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _profile?['fullName'] as String? ?? '';
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          } else {
            setState(() => _navIndex = i);
          }
        },
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch trình'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Gói dịch vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            AnimatedEntry(delay: 100, child: header(userName)),
            const SizedBox(height: 8),
            AnimatedEntry(delay: 200, child: statusCard(purple)),
            const SizedBox(height: 8),
            AnimatedEntry(delay: 300, child: bannerCarousel()),
            const SizedBox(height: 8),
            AnimatedEntry(delay: 400, child: carouselIndicator()),
            const SizedBox(height: 16),
            AnimatedEntry(delay: 500, child: quickAccess(purple)),
            const SizedBox(height: 24),
            AnimatedEntry(delay: 600, child: usefulSuggestions(purple)),
          ],
        ),
      ),
    );
  }

  // Widget header(String userName) => Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //   child: Row(
  //     children: [
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Chào buổi tối 👋', style: TextStyle(fontSize: 16, color: purple.shade700)),
  //             const SizedBox(height: 4),
  //             Text(userName,
  //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: purple.shade900)),
  //           ],
  //         ),
  //       ),
  //       Container(
  //         decoration: BoxDecoration(color: purple, shape: BoxShape.circle),
  //         padding: const EdgeInsets.all(12),
  //         child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
  //       ),
  //     ],
  //   ),
  // );

  Widget header(String userName) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chào buổi tối 👋', style: TextStyle(fontSize: 16, color: purple.shade700)),
              const SizedBox(height: 4),
              Text(userName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: purple.shade900)),
            ],
          ),
        ),
        // Đổi Icon thành InkWell/ElevatedButton/IconButton...
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChatPage()), // <-- Đổi tên nếu file khác
            );
          },
          child: Container(
            decoration: BoxDecoration(color: purple, shape: BoxShape.circle),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
      ],
    ),
  );


  Widget statusCard(Color purple) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Trạng thái hôm nay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Bạn đang cảm thấy thế nào?'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },

            style: ElevatedButton.styleFrom(backgroundColor: purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Dashboard'),
          ),
        ],
      ),
    ),
  );

  Widget bannerCarousel() => SizedBox(
    height: 200,
    child: PageView.builder(
      controller: _bannerController,
      itemCount: 3,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.only(left: i == 0 ? 24 : 0, right: i == 2 ? 24 : 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/emoEase.jpg', fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black26, Colors.transparent]),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Dành Cho Ai', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Chăm sóc sức khỏe tinh thần', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget carouselIndicator() => Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
            (i) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _bannerIndex == i ? purple : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );

  Widget quickAccess(Color purple) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const QuickTile(icon: Icons.calendar_today, label: 'Lịch trình'),
        const QuickTile(icon: Icons.psychology, label: 'Đánh giá'),
        const QuickTile(icon: Icons.group, label: 'Hồ sơ'),
        QuickTile(
          icon: Icons.chat_bubble,
          label: 'Emo',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatPage()),
            );
          },
        ),
      ],
    ),
  );


  Widget usefulSuggestions(Color purple) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Gợi ý hữu ích', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: purple)),
            TextButton(onPressed: () {}, child: Text('Xem tất cả', style: TextStyle(color: purple))),
          ],
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: 4,
          itemBuilder: (context, i) => Padding(
            padding: EdgeInsets.only(right: i == 3 ? 0 : 16),
            child: AnimatedEntry(
              delay: 700 + i * 100,
              child: Container(
                width: 140,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 80),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Thiền chánh', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delay; // in ms
  const AnimatedEntry({required this.child, required this.delay, Key? key}) : super(key: key);

  @override
  _AnimatedEntryState createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

class QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const QuickTile({required this.icon, required this.label, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final purple = Colors.deepPurple;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: purple.shade50, shape: BoxShape.circle),
            child: Icon(icon, color: purple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
