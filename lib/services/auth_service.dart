// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pe_emoease_mobileapp_flutter/utils/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Base URL của API
  static const String _baseUrl = 'https://api.emoease.vn/auth-service/Auth';

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');
    final clientDeviceId = await DeviceUtils.getDeviceId();
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'clientDeviceId': "BP22.250325.006",
          'deviceType': "Android"
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        String token = data['token'];

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        return data['token'] as String?;
      } else {
        print('Login thất bại: ${response.statusCode} – ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi gọi API login: $e');
      return null;
    }
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
  Future<bool> register({
    required String fullName,
    required String gender,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');
    final body = jsonEncode({
      'fullName': fullName,
      'gender': gender,
      'email': email,
      'phoneNumber': phone,
      'password': password,
      'confirmPassword': confirmPassword
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      // In log chi tiết để debug:
      print('REGISTER → status: ${response.statusCode}');
      print('REGISTER → body: ${response.body}');

      // Cho cả 200 và 201
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi khi gọi API register: $e');
      return false;
    }
  }
}
