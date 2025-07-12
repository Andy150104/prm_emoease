import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatService {
  static const String _baseUrl = 'https://api.emoease.vn/chatbox-service/api/AIChat';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Lấy danh sách phiên chat (có phân trang)
  Future<List<ChatSession>> fetchSessions({int pageIndex = 1, int pageSize = 20}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập!');

    final res = await http.get(
      Uri.parse('$_baseUrl/sessions?PageIndex=$pageIndex&PageSize=$pageSize'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final sessions = (data['data'] as List?)
          ?.map((e) => ChatSession.fromJson(e))
          .toList() ??
          [];
      return sessions;
    } else {
      throw Exception('Không thể tải phiên chat: ${res.body}');
    }
  }

  // Tạo phiên chat mới (có thể truyền tên)
  Future<ChatSession> createSession({String? sessionName}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập!');
    final uri = sessionName != null && sessionName.isNotEmpty
        ? Uri.parse('$_baseUrl/sessions?sessionName=${Uri.encodeComponent(sessionName)}')
        : Uri.parse('$_baseUrl/sessions');
    final res = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return ChatSession.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Không thể tạo phiên chat: ${res.body}');
    }
  }

  // Xoá phiên chat
  Future<bool> deleteSession(String sessionId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập!');
    final res = await http.delete(
      Uri.parse('$_baseUrl/sessions/$sessionId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      return true;
    } else {
      throw Exception('Không thể xoá phiên chat: ${res.body}');
    }
  }

  // Lấy danh sách tin nhắn của 1 phiên (có phân trang)
  Future<List<ChatMessage>> fetchMessages({
    required String sessionId,
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập!');

    final res = await http.get(
      Uri.parse('$_baseUrl/sessions/$sessionId/messages?PageIndex=$pageIndex&PageSize=$pageSize'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final messages = (data['data'] as List?)
          ?.map((e) => ChatMessage.fromJson(e))
          .toList() ??
          [];
      return messages;
    } else {
      throw Exception('Không thể tải tin nhắn: ${res.body}');
    }
  }

  // Gửi tin nhắn mới (trả về danh sách tin nhắn AI trả lời, có thể nhiều)
  Future<List<ChatMessage>> sendMessage({
    required String sessionId,
    required String userMessage,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập!');

    final res = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userMessage': userMessage,
        'sessionId': sessionId,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // API trả về có thể là 1 list hoặc 1 message, chuẩn nhất vẫn là list
      final rawMessages = data is List ? data : data['data'];
      final messages = (rawMessages as List?)
          ?.map((e) => ChatMessage.fromJson(e))
          .toList() ??
          [];
      return messages;
    } else if (res.statusCode == 500) {
      final data = jsonDecode(res.body);
      if (data['detail']?.toString().contains('default credentials') == true) {
        throw Exception('AI service tạm thời không khả dụng. Vui lòng liên hệ admin.');
      }
      throw Exception('Không thể gửi tin nhắn: ${res.body}');
    } else {
      throw Exception('Không thể gửi tin nhắn: ${res.body}');
    }
  }

  // Đánh dấu đã đọc tất cả tin nhắn trong 1 session
  Future<bool> markMessagesAsRead(String sessionId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Chưa đăng nhập!');
    final res = await http.put(
      Uri.parse('$_baseUrl/sessions/$sessionId/messages/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      return true;
    } else {
      throw Exception('Không thể đánh dấu đã đọc: ${res.body}');
    }
  }

  // Xử lý delayed message (UI có thể gọi hàm này để delay hiển thị message AI tiếp theo)
  Future<ChatMessage> delayedMessage(ChatMessage message, int delayMs) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    return message;
  }
}
