import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_result.dart';

class TestService {
  final String _baseUrl = 'https://api.emoease.vn/test-service';

  Future<TestResult> submitTestResult({
    required String testId,
    required List<String> selectedOptionIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    if (token.isEmpty) throw Exception('No access token');

    // Giải mã lấy patientId
    final decoded = JwtDecoder.decode(token);
    final patientId = decoded['profileId'] as String?;
    print('▶️ [Debug] patientId from token: $patientId');

    final uri = Uri.parse('$_baseUrl/test-results');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final payloadMap = {
      'patientId': patientId,
      'testId': testId,
      'selectedOptionIds': selectedOptionIds,
    };
    final payload = jsonEncode(payloadMap);

    // In toàn bộ REQUEST
    print('▶️ [Debug] POST $uri');
    print('▶️ [Debug] Request headers: $headers');
    print('▶️ [Debug] Request body: $payload');

    final resp = await http.post(uri, headers: headers, body: payload);

    // In toàn bộ RESPONSE
    print('▶️ [Debug] Status code: ${resp.statusCode}');
    print('▶️ [Debug] Response headers: ${resp.headers}');
    print('▶️ [Debug] Response body: ${resp.body}');

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body)['testResult'] as Map<String, dynamic>;
      return TestResult.fromJson(body);
    } else {
      throw Exception('Submit failed: ${resp.statusCode}');
    }
  }
}
