// lib/services/profile_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _baseUrl = 'https://api.emoease.vn/profile-service';

  Future<Map<String, dynamic>> fetchPatientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }
    print('▶️ Token: $token');

    Map<String, dynamic> payload = JwtDecoder.decode(token);
    print('▶️ JWT payload: $payload');

    // Dùng đúng key claim, thử cả 'profileId' và 'sub'
    final profileId = (payload['profileId'] ?? payload['sub'])?.toString();
    if (profileId == null || profileId.isEmpty) {
      throw Exception('Claim profileId không tồn tại trong token');
    }

    final uri = Uri.parse('$_baseUrl/patients/$profileId');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('▶️ GET $uri → ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('▶️ Response body: ${response.body}');
        throw Exception('Lấy profile thất bại [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      // có thể là lỗi mạng, in thêm chi tiết
      print('❌ Error when fetching profile: $e');
      rethrow;
    }
  }

}
