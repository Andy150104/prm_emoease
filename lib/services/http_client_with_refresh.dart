import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class HttpClientWithRefresh {
  static Future<http.Response> get(Uri uri) async {
    final token = await _getAccessToken();
    http.Response response = await _sendGet(uri, token);

    if (response.statusCode == 401) {
      final newToken = await AuthService().refreshToken();
      if (newToken != null) {
        response = await _sendGet(uri, newToken);
      } else {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
    }

    return response;
  }

  static Future<http.Response> _sendGet(Uri uri, String token) {
    return http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  static Future<http.Response> put(Uri uri, {Map<String, String>? headers, Object? body}) async {
    final token = await _getAccessToken();
    http.Response response = await _sendPut(uri, token, headers: headers, body: body);

    if (response.statusCode == 401) {
      final newToken = await AuthService().refreshToken();
      if (newToken != null) {
        response = await _sendPut(uri, newToken, headers: headers, body: body);
      } else {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
    }

    return response;
  }

  static Future<http.Response> _sendPut(Uri uri, String token, {Map<String, String>? headers, Object? body}) {
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };
    
    return http.put(uri, headers: requestHeaders, body: body);
  }

  static Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('Không tìm thấy access_token');
    return token;
  }

  static Future<http.Response> put(Uri uri, {Map<String, String>? headers, Object? body}) async {
    final token = await _getAccessToken();
    http.Response response = await _sendPut(uri, token, headers, body);

    if (response.statusCode == 401) {
      final newToken = await AuthService().refreshToken();
      if (newToken != null) {
        response = await _sendPut(uri, newToken, headers, body);
      } else {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
    }

    return response;
  }

  static Future<http.Response> _sendPut(Uri uri, String token, Map<String, String>? headers, Object? body) {
    final allHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };
    return http.put(uri, headers: allHeaders, body: body);
  }
}
