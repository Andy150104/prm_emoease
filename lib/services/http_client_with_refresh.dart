// lib/services/http_client_with_refresh.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class HttpClientWithRefresh {
  // private constructor để tránh khởi tạo
  HttpClientWithRefresh._();

  /// GET với auto-refresh khi 401
  static Future<http.Response> get(
      Uri uri, {
        Map<String, String>? headers,
      }) async {
    final token = await _getAccessToken();
    var response = await _sendRequest(
      'GET',
      uri,
      token,
      headers: headers,
    );
    if (response.statusCode == 401) {
      final newToken = await AuthService().refreshToken();
      if (newToken != null) {
        response = await _sendRequest(
          'GET',
          uri,
          newToken,
          headers: headers,
        );
      } else {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
    }
    return response;
  }

  /// PUT với auto-refresh khi 401
  static Future<http.Response> put(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final token = await _getAccessToken();
    var response = await _sendRequest(
      'PUT',
      uri,
      token,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 401) {
      final newToken = await AuthService().refreshToken();
      if (newToken != null) {
        response = await _sendRequest(
          'PUT',
          uri,
          newToken,
          headers: headers,
          body: body,
        );
      } else {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
    }
    return response;
  }

  /// Helper chung cho GET/PUT (và dễ mở rộng POST, DELETE…)
  static Future<http.Response> _sendRequest(
      String method,
      Uri uri,
      String token, {
        Map<String, String>? headers,
        Object? body,
      }) {
    final allHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };
    final encodedBody = body != null ? jsonEncode(body) : null;

    switch (method) {
      case 'GET':
        return http.get(uri, headers: allHeaders);
      case 'PUT':
        return http.put(uri, headers: allHeaders, body: encodedBody);
      default:
        throw UnsupportedError('Method $method chưa được hỗ trợ');
    }
  }

  /// Lấy access token từ SharedPreferences
  static Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access_token');
    }
    return token;
  }
}
