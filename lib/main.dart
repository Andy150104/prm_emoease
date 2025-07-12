//main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/therapeutic_activities_page.dart';
import 'pages/physical_activities_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final bool hasValidToken = token != null && !JwtDecoder.isExpired(token);

  runApp(MyApp(hasValidToken: hasValidToken));
}

class MyApp extends StatelessWidget {
  final bool hasValidToken;
  const MyApp({required this.hasValidToken, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoease',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      // Nếu đã có token còn hạn, chuyển thẳng đến HomePage, ngược lại về LoginPage
      home: hasValidToken ? const HomePage() : const LoginPage(),
      routes: {
        '/therapeutic-activities': (context) => const TherapeuticActivitiesPage(),
        '/physical-activities': (context) => const PhysicalActivitiesPage(),
      },
    );
  }
}
