import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/payment_webview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/profile_service.dart';
import '../services/subscription_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  SubscriptionService? _service;
  final TextEditingController _promoCodeController = TextEditingController();

  bool _loading = true;
  List<dynamic> _plans = [];
  String? _selectedPlanId;
  String? _error;
  String? _patientId; // 👈 Thêm dòng này

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      _service = await SubscriptionService.create();
      _patientId = await ProfileService.getPatientProfileIdFromToken(); // 👈 Lấy patientId trước
      await _fetchPlans();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Lỗi khởi tạo: $e';
      });
    }
  }

  Future<void> _fetchPlans() async {
    if (_service == null) return;

    try {
      final plans = await _service!.getServicePackages(); // 👈 Không truyền patientId
      setState(() {
        _plans = plans;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _plans = [];
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _onSelectPlan(String planId) {
    setState(() {
      _selectedPlanId = planId;
    });
  }

  Future<void> _onUpgradePressed() async {
    if (_service == null || _selectedPlanId == null || _patientId == null) return;

    final selectedPlan = _plans.firstWhere(
          (p) => p['id'] == _selectedPlanId,
      orElse: () => null,
    );

    if (selectedPlan == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn nâng cấp gói này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xác nhận')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final String? promoCode = _promoCodeController.text.trim().isNotEmpty
          ? _promoCodeController.text.trim()
          : null;

      final String paymentUrl = await _service!.createUserSubscription(
        patientId: _patientId!,
        servicePackageId: selectedPlan['id'],
        paymentMethodName: 'VNPay',
        promoCode: promoCode,
      );

      if (context.mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentWebView(url: paymentUrl)),
        );

        if (result == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thành công')),
          );
          await _fetchPlans(); // hoặc load lại trạng thái
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thất bại hoặc bị huỷ')),
          );
        }

      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(title: const Text('Gói dịch vụ'), backgroundColor: purple),
      backgroundColor: const Color(0xFFF8F6FC),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Lỗi khi tải gói dịch vụ:\n$_error'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._plans.map((plan) => _buildPlanCard(plan, purple)),
            if (_selectedPlanId != null) _buildPlanDetails(purple),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan, Color purple) {
    return GestureDetector(
      onTap: () => _onSelectPlan(plan['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedPlanId == plan['id'] ? purple : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: purple),
                const SizedBox(width: 8),
                Text(
                  plan['name'] ?? 'Không tên',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${plan['price'] ?? 0}₫',
              style: TextStyle(color: purple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails(Color purple) {
    final selectedPlan = _plans.firstWhere((p) => p['id'] == _selectedPlanId, orElse: () => null);
    if (selectedPlan == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chi tiết gói: ${selectedPlan['name']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Bullet(text: selectedPlan['description'] ?? 'Không có mô tả'),
              const SizedBox(height: 16),
              const Text('Mã khuyến mãi (tùy chọn):'),
              const SizedBox(height: 8),
              TextField(
                controller: _promoCodeController,
                decoration: const InputDecoration(
                  hintText: 'Nhập mã khuyến mãi',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onUpgradePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Nâng cấp gói'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class Bullet extends StatelessWidget {
  final String text;
  const Bullet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
