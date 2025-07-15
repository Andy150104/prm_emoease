// login_page.dart
import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/home_page.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/register_page.dart';
import '../services/auth_service.dart';
import '../main.dart' show scheduleAutoLogout;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  final _auth = AuthService();

  void _onLogin() async {
    setState(() => _loading = true);
    final token = await _auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    setState(() => _loading = false);

    if (token != null) {
      scheduleAutoLogout();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email hoặc mật khẩu không đúng')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [ Color(0xFFF3E5F5), Color(0xFFE1BEE7) ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text('Emoease',
                  style: TextStyle(fontFamily: 'Pacifico', fontSize: 36, color: Colors.deepPurple),
                ),
                const SizedBox(height: 8),
                Text('Chào mừng trở lại! 👋',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple.shade700),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [ BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0,8)) ],
                  ),
                  child: Column(
                    children: [
                      // Email
                      Align(alignment: Alignment.centerLeft,
                        child: Text('Email',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple.shade700, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                          hintText: 'Bạn nhập email ở đây',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple.shade700, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mật khẩu
                      Align(alignment: Alignment.centerLeft,
                        child: Text('Mật khẩu',
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple.shade700, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.deepPurple),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          hintText: '••••••••',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple.shade700, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nút đăng nhập
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Đăng nhập 🚀', style: TextStyle(fontSize: 18)),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () { /* quên mật khẩu */ },
                        child: Text('Quên mật khẩu? 🤔', style: TextStyle(color: Colors.deepPurple.shade700)),
                      ),

                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('hoặc', style: TextStyle(color: Colors.grey))),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ]),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có tài khoản? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              );
                            }, // chuyển sang trang Đăng ký
                            child: Text('Đăng ký ngay! ✨',
                              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
