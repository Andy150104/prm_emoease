// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pe_emoease_mobileapp_flutter/utils/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('refresh_token', refreshToken);
        return token;
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
    await prefs.remove('refresh_token');
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

      print('REGISTER → status: ${response.statusCode}');
      print('REGISTER → body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi khi gọi API register: $e');
      return false;
    }
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (token == null || refreshToken == null) return null;

    final uri = Uri.parse('$_baseUrl/refresh-token');
    final body = jsonEncode({
      'token': token,
      'refreshToken': refreshToken,
      'clientDeviceId': await DeviceUtils.getDeviceId(),
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'];
        final newRefresh = data['refreshToken'];

        await prefs.setString('access_token', newToken);
        await prefs.setString('refresh_token', newRefresh);
        return newToken;
      } else {
        print('Refresh token thất bại: ${response.statusCode} – ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi gọi refresh token: $e');
      return null;
    }
  }
}
