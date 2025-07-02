// profile_page.dart
import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/home_page.dart';
import 'package:pe_emoease_mobileapp_flutter/services/auth_service.dart';
import 'package:pe_emoease_mobileapp_flutter/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final purple = Colors.deepPurple;
  int _navIndex = 3;
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService().fetchPatientProfile();
      setState(() {
        _profile = data['patientProfileDto'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải hồ sơ: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_profile.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(top: 0, bottom: 16),
              children: [
                // a) Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white54,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Chỉnh sửa'),
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // b) Card Profile chính
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 36,
                                backgroundImage: AssetImage('assets/images/avatar.jpg'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_profile?['fullName'] ?? '',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: purple,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text('Người dùng', style: TextStyle(color: Colors.white)),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.green),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.check_circle, size: 16, color: Colors.green),
                                              SizedBox(width: 4),
                                              Text('Đã xác thực', style: TextStyle(color: Colors.green)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(_profile?['contactInfo']?['email'] ?? ''),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // c) Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _ActionTile(icon: Icons.assignment, label: 'Làm bài test\nDASS-21'),
                      _ActionTile(icon: Icons.spa, label: 'Hoạt động\ntrị liệu'),
                      _ActionTile(icon: Icons.fitness_center, label: 'Hoạt động\nthể chất'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // d) Thông tin cá nhân
                _InfoCard(
                  title: 'Thông tin cá nhân',
                  fields: [
                    _InfoField(label: 'Họ và tên', value: _profile?['fullName'] ?? ''),
                    _InfoField(label: 'Giới tính', value: _profile?['gender'] ?? ''),
                    _InfoField(label: 'Ngày sinh', value: _profile?['birthDate'] ?? ''),
                    _InfoField(label: 'Tính cách', value: _profile?['personalityTraits'] ?? ''),
                    _InfoField(label: 'Dị ứng', value: _profile?['allergies'] ?? ''),
                    _InfoField(label: 'Trình độ học vấn', value: _profile?['job']?['educationLevel'] ?? ''),
                    _InfoField(label: 'Nghề nghiệp', value: _profile?['job']?['jobTitle'] ?? ''),
                    _InfoField(label: 'Ngành nghề', value: _profile?['job']?['industry']?['industryName'] ?? ''),
                  ],
                ),

                const SizedBox(height: 16),

                // e) Thông tin liên hệ
                _InfoCard(
                  title: 'Thông tin liên hệ',
                  fields: [
                    _InfoField(label: 'Email', value: _profile?['contactInfo']?['email'] ?? ''),
                    _InfoField(label: 'Số điện thoại', value: _profile?['contactInfo']?['phoneNumber'] ?? ''),
                    _InfoField(label: 'Địa chỉ', value: _profile?['contactInfo']?['address'] ?? ''),
                  ],
                ),

                const SizedBox(height: 32),

                // f) Logout button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Icon(icon, size: 32, color: Colors.deepPurple),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoField> fields;
  const _InfoCard({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20),
              ...fields.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.label),
                    Flexible(child: Text(f.value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField {
  final String label;
  final String value;
  const _InfoField({required this.label, required this.value});
}
