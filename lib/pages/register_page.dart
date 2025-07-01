// register_page.dart
import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/login_page.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _gender;
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  final List<Map<String,String>> _genders = [
    {'value': 'Male',   'label': 'Nam'},
    {'value': 'Female', 'label': 'Nữ'},
    {'value': 'Else',   'label': 'Khác'},
  ];

  final _authService = AuthService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    final success = await _authService.register(
      fullName: _nameCtrl.text.trim(),
      gender: _gender!,            // "Male" | "Female" | "Else"
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.deepPurple),
    );

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade50,
        elevation: 0,
        leading: const BackButton(color: Colors.deepPurple),
        title: const Text('Tạo tài khoản mới ✨', style: TextStyle(color: Colors.deepPurple)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Họ và tên
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: const Icon(Icons.person),
                          border: border,
                        ),
                        validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                      ),
                      const SizedBox(height: 16),

                      // Giới tính
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: _genders.map((g) => DropdownMenuItem(
                          value: g['value'],
                          child: Text(g['label']!),
                        )).toList(),
                        onChanged: (v) => setState(() => _gender = v),
                        validator: (v) => v == null ? 'Chọn giới tính' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: border,
                          hintText: 'example@email.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.contains('@') ? null : 'Email không hợp lệ',
                      ),
                      const SizedBox(height: 16),

                      // SĐT
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: const Icon(Icons.phone),
                          border: border,
                          hintText: '0123456789',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.length >= 9 ? null : 'Số điện thoại không hợp lệ',
                      ),
                      const SizedBox(height: 16),

                      // Mật khẩu
                      TextFormField(
                        controller: _passCtrl,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          border: border,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        obscureText: _obscurePass,
                        validator: (v) => v!.length >= 6 ? null : 'Tối thiểu 6 ký tự',
                      ),
                      const SizedBox(height: 16),

                      // Xác nhận mật khẩu
                      TextFormField(
                        controller: _confirmCtrl,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          border: border,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        obscureText: _obscureConfirm,
                        validator: (v) => v == _passCtrl.text ? null : 'Mật khẩu không khớp',
                      ),
                      const SizedBox(height: 24),

                      // Button Đăng ký
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submit,
                          child: const Text('Đăng ký ✨', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Chuyển sang Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?'),
                  TextButton(
                    onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                    },
                    child: const Text('Đăng nhập ngay!', style: TextStyle(color: Colors.deepPurple)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
