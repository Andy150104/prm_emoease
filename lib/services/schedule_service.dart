// lib/services/schedule_service.dart
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pe_emoease_mobileapp_flutter/services/http_client_with_refresh.dart';

class ScheduleService {
  static const String _baseUrl = 'https://api.emoease.vn/scheduling-service';

  Future<Map<String, dynamic>> fetchSchedules({
    required int pageIndex,
    required int pageSize,
  }) async {
    print('[Service] Lấy SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access_token');
    print('[Service] Token: $token');

    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    final payload = JwtDecoder.decode(token);
    print('[Service] Payload: $payload');

    final patientId = (payload['profileId'] ?? payload['sub'])?.toString();
    print('[Service] patientId: $patientId');

    if (patientId == null || patientId.isEmpty) {
      throw Exception('Claim profileId không tồn tại trong token');
    }

    final uri = Uri.parse(
      '$_baseUrl/schedules?PageIndex=$pageIndex&PageSize=$pageSize&SortBy=startDate&SortOrder=asc&PatientId=$patientId',
    );
    print('[Service] Gọi API: $uri');

    final response = await HttpClientWithRefresh.get(uri);
    print('[Service] Status code: ${response.statusCode}');
    print('[Service] Body: ${response.body}');

    final data = jsonDecode(response.body);
    final schedules = data['schedules'] as Map<String, dynamic>;

    if (!schedules.containsKey('data')) {
      throw Exception('Kết quả không có "data"');
    }

    return schedules;
  }


  Future<Map<String, dynamic>> fetchActivities(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    final uri = Uri.parse('$_baseUrl/schedule-activities/$sessionId');
    final response = await HttpClientWithRefresh.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Lỗi lấy hoạt động [${response.statusCode}]: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchTotalSessions({
    required String scheduleId,
    required String startDate,
    required String endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    final uri = Uri.parse(
      '$_baseUrl/schedule/get-total-sessions?ScheduleId=$scheduleId&StartDate=$startDate&EndDate=$endDate',
    );
    
    final response = await HttpClientWithRefresh.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Lỗi lấy tổng phiên [${response.statusCode}]: ${response.body}');
    }
  }

  Future<int> getTotalSessionsCountForSchedule({
    required String scheduleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    final formattedStart = startDate.toIso8601String();
    final formattedEnd = endDate.toIso8601String();

    final uri = Uri.parse(
      '$_baseUrl/schedule/get-total-sessions'
          '?ScheduleId=$scheduleId'
          '&StartDate=$formattedStart'
          '&EndDate=$formattedEnd',
    );

    final response = await HttpClientWithRefresh.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> sessions = data['sessions'] ?? [];
      return sessions.length;
    } else {
      throw Exception('Lỗi lấy tổng số phiên [${response.statusCode}]: ${response.body}');
    }
  }


  Future<bool> updateActivityStatus({
    required String taskId,
    required String sessionsForDate,
    required String newStatus, // 'Completed' or 'Pending'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Không tìm thấy access token, vui lòng login lại');
    }

    final uri = Uri.parse('$_baseUrl/schedule-activities/$taskId/$sessionsForDate/status');
    
    final response = await HttpClientWithRefresh.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Lỗi cập nhật trạng thái [${response.statusCode}]: ${response.body}');
    }
  }
} 