import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pe_emoease_mobileapp_flutter/services/http_client_with_refresh.dart';

class LifestyleService {
  static const _baseUrl = 'https://api.emoease.vn/lifestyle-service';

  Future<List<dynamic>> fetchTherapeuticActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }
    final uri = Uri.parse('$_baseUrl/therapeutic-activities');
    final response = await HttpClientWithRefresh.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['therapeuticActivities']['data'] as List<dynamic>;
    } else {
      throw Exception('Lỗi lấy hoạt động trị liệu [${response.statusCode}]: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchPhysicalActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }
    final uri = Uri.parse('$_baseUrl/physical-activities');
    final response = await HttpClientWithRefresh.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['physicalActivities']['data'] as List<dynamic>;
    } else {
      throw Exception('Lỗi lấy hoạt động thể chất [${response.statusCode}]: ${response.body}');
    }
  }

  Future<void> savePatientPhysicalActivities(String patientProfileId, List activities) async {
    final uri = Uri.parse('$_baseUrl/patient-Physical-activities');
    final body = jsonEncode({
      'patientProfileId': patientProfileId,
      'activities': activities,
    });
    final response = await HttpClientWithRefresh.put(
      uri,
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Lỗi lưu hoạt động thể chất [${response.statusCode}]: ${response.body}');
    }
  }

  Future<void> savePatientTherapeuticActivities(String patientProfileId, List activities) async {
    // Debug: print the request body
    final bodyMap = {
      'patientProfileId': patientProfileId,
      'activities': activities,
    };
    print('PUT /patient-therapeutic-activities body: ' + jsonEncode(bodyMap));
    final uri = Uri.parse('$_baseUrl/patient-therapeutic-activities');
    final body = jsonEncode(bodyMap);
    final response = await HttpClientWithRefresh.put(
      uri,
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      print('Response body: ' + response.body);
      throw Exception('Lỗi lưu hoạt động trị liệu [${response.statusCode}]: ${response.body}');
    }
  }
}
