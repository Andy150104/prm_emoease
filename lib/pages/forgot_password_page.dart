// lib/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();

  Future<void> _onSubmit() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vui lòng nhập email')));
      return;
    }

    setState(() => _loading = true);
    final success = await _auth.forgotPassword(email: email);
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra email để đặt lại mật khẩu')),
      );
      Navigator.of(context).pop(); // quay về trang login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi yêu cầu thất bại, thử lại sau')),
      );
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
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 36,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Quên mật khẩu? 🕵️‍♀️',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0,8))
                    ],
                  ),
                  child: Column(
                    children: [
                      // Email
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                          hintText: 'Nhập email của bạn',
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
                      // Nút gửi yêu cầu
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Gửi yêu cầu', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Quay lại đăng nhập
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Quay lại đăng nhập',
                          style: TextStyle(color: Colors.deepPurple.shade700),
                        ),
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
