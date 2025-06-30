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

    Map<String, dynamic> payload = JwtDecoder.decode(token);

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
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Lấy profile thất bại [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

}
