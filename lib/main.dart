import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';



final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final hasValid = token != null && !JwtDecoder.isExpired(token);

  // Nếu token còn hạn, khởi tạo Timer tự động logout
  if (hasValid) {
    scheduleAutoLogout();
  }

  runApp(MyApp(hasValidToken: hasValid));
}

class MyApp extends StatelessWidget {
  final bool hasValidToken;
  const MyApp({required this.hasValidToken, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: hasValidToken ? const HomePage() : const LoginPage(),
    );
  }
}

// Hàm đặt lịch tự logout
void scheduleAutoLogout() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  if (token == null) return; // chưa login

  DateTime exp = JwtDecoder.getExpirationDate(token);
  Duration untilExpire = exp.difference(DateTime.now());

  // Nếu đã quá hạn thì logout ngay
  if (untilExpire.isNegative) {
    _doLogout();
  } else {
    Timer(untilExpire, _doLogout);
  }
}

void _doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');

  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
  );
  messengerKey.currentState?.showSnackBar(
    const SnackBar(content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.')),
  );
}