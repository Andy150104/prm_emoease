import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pe_emoease_mobileapp_flutter/services/profile_service.dart';

class SubscriptionService {
  final Dio _dio;

  SubscriptionService._internal(this._dio);

  static Future<SubscriptionService> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.emoease.vn/subscription-service',
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    return SubscriptionService._internal(dio);
  }

  Future<void> _attachAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print("📌 Token hiện tại: $token");
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      print('❌ Không tìm thấy access token – user chưa login?');
    }
  }

  Future<List<dynamic>> getServicePackages() async {
    try {
      await _attachAuthHeader();
      print('👉 Gọi API GET /service-packages');
      final response = await _dio.get('/service-packages');

      print('✅ Dữ liệu gói dịch vụ: ${response.data}');
      return response.data['servicePackages']?['data'] ?? [];
    } catch (e) {
      print('❌ Lỗi khi fetch gói dịch vụ: $e');
      throw Exception('Không thể lấy danh sách gói dịch vụ: $e');
    }
  }

  Future<String> createUserSubscription({
    required String patientId,
    required String servicePackageId,
    required String paymentMethodName,
    String? promoCode,
    String? giftId,
  }) async {
    try {
      await _attachAuthHeader();

      final payload = {
        "userSubscription": {
          "patientId": patientId,
          "servicePackageId": servicePackageId,
          "promoCode": null,
          "giftId": null,
          "startDate": DateTime.now().toIso8601String(),
          "paymentMethodName": paymentMethodName,
          if (promoCode != null && promoCode.isNotEmpty) "promoCode": promoCode,
          if (giftId != null && giftId.isNotEmpty) "giftId": giftId,
        }
      };

      print('👉 Gửi POST /user-subscriptions với dữ liệu: $payload');
      final response = await _dio.post('/user-subscriptions', data: payload);
      print('✅ Subscription tạo thành công: ${response.data}');
      return response.data['paymentUrl'];
    } catch (e) {
      print('❌ Lỗi khi tạo subscription: $e');
      throw Exception('Không thể tạo subscription: $e');
    }
  }

}
