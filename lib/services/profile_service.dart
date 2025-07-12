// lib/services/profile_service.dart
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pe_emoease_mobileapp_flutter/services/http_client_with_refresh.dart';

class ProfileService {
  static const _baseUrl = 'https://api.emoease.vn/profile-service';

  Future<Map<String, dynamic>> fetchPatientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    final payload = JwtDecoder.decode(token);
    final profileId = (payload['profileId'] ?? payload['sub'])?.toString();
    if (profileId == null || profileId.isEmpty) {
      throw Exception('Claim profileId không tồn tại trong token');
    }

    final uri = Uri.parse('$_baseUrl/patients/$profileId');
    final response = await HttpClientWithRefresh.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi lấy thông tin hồ sơ [${response.statusCode}]: ${response.body}');
    }
  }

  Future<void> updatePatientProfile(String id, Map<String, dynamic> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    // Loại bỏ jobId nếu rỗng
    if (updatedData['jobId'] == null || updatedData['jobId'].toString().isEmpty) {
      updatedData.remove('jobId');
    }

    final uri = Uri.parse('$_baseUrl/patients/$id');
    print('[DEBUG] Sending updatePatientProfile data: ' + jsonEncode({'patientProfileUpdate': updatedData}));
    final response = await HttpClientWithRefresh.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'patientProfileUpdate': updatedData}),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi cập nhật hồ sơ [${response.statusCode}]: ${response.body}');
    }
  }
}
