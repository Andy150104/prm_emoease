// lib/services/question_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class QuestionService {
  final String _baseUrl = 'https://api.emoease.vn/test-service/test-questions';

  Future<List<Question>> fetchQuestions(String testId, {int pageSize = 21}) async {
    final uri = Uri.parse('$_baseUrl/$testId?pageSize=$pageSize');
    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('access_token') ?? '';

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $rawToken',
      'accept': '*/*',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['testQuestions']['data'] as List;

      return items.map((item) {
        final opts = (item['options'] as List).map((opt) {
          return Option(
            id: opt['id'] as String,
            content: opt['content'] as String,
          );
        }).toList();

        return Question(
          id: item['id'] as String,
          content: item['content'] as String,
          options: opts,
        );
      }).toList();
    } else {
      throw Exception('Failed to load questions (${response.statusCode})');
    }
  }
}
