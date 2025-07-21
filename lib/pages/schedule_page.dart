import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/http_client_with_refresh.dart';
import '../services/schedule_service.dart';
import 'schedule_detail_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _loading = true;
  List<dynamic> _schedules = [];
  Map<String, int> _sessionCounts = {};
  Map<String, int> _activityCounts = {};
  int _pageIndex = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi').then((_) {
      _fetchSchedules();
    });
  }

  Future<void> _fetchSchedules() async {
    print('⏳ Fetching schedules...');
    setState(() => _loading = true);
    try {
      final result = await _scheduleService.fetchSchedules(
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      print('Schedules loaded: ${result['data']?.length ?? 0} items');
      final schedules = result['data'] ?? [];
      setState(() {
        _schedules = schedules;
        _loading = false;
      });
      // Fetch total sessions and activities for each schedule
      for (var item in schedules) {
        final id = item['id'].toString();
        final startDate = item['startDate'] ?? '';
        final endDate = item['endDate'] ?? '';
        if (startDate.isNotEmpty && endDate.isNotEmpty) {
          try {
            // Lấy danh sách các session
            final uri = Uri.parse(
              'https://api.emoease.vn/scheduling-service/schedule/get-total-sessions'
              '?ScheduleId=$id'
              '&StartDate=${DateTime.parse(startDate).toIso8601String()}'
              '&EndDate=${DateTime.parse(endDate).toIso8601String()}',
            );
            final response = await HttpClientWithRefresh.get(uri);
            final data = jsonDecode(response.body);
            final List<dynamic> sessions = data['sessions'] ?? [];
            setState(() {
              _sessionCounts[id] = sessions.length;
            });
            // Đếm tổng số activity của tất cả session
            int totalActivities = 0;
            for (var session in sessions) {
              final sessionId = session['id'].toString();
              try {
                final activitiesRes = await _scheduleService.fetchActivities(sessionId);
                final activities = activitiesRes['items'] ?? activitiesRes['activities'] ?? [];
                totalActivities += activities is List ? activities.length : 0;
              } catch (e) {
                print('Error fetching activities for session $sessionId: $e');
              }
            }
            setState(() {
              _activityCounts[id] = totalActivities;
            });
          } catch (e) {
            print('Error fetching session count for $id: $e');
          }
        }
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = Colors.deepPurple;
    final gradientColors = [purple, Color(0xFFB39DDB)];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          color: purple,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 32), // tăng bottom để khung tím dư ra dưới
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Lịch trình của bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Quản lý hoạt động hàng ngày',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_schedules.isNotEmpty) ...[
              Center(
                child: Container(
                  width: 380,
                  constraints: const BoxConstraints(maxWidth: 500),
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (_) {
                      final schedule = _schedules[0];
                      final startDate = schedule['startDate'] != null ? DateTime.parse(schedule['startDate']) : null;
                      final endDate = schedule['endDate'] != null ? DateTime.parse(schedule['endDate']) : null;
                      String dateRange = '';
                      if (startDate != null && endDate != null) {
                        dateRange = '${startDate.day} thg ${startDate.month} - ${endDate.day} thg ${endDate.month}, ${endDate.year}';
                      }
                      final sessionCount = _sessionCounts[schedule['id'].toString()] ?? 0;
                      final activityCount = _activityCounts[schedule['id'].toString()] ?? 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.assignment_turned_in, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Lịch trình điều trị',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.date_range, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                dateRange,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.list_alt, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$sessionCount phiên - $activityCount hoạt động',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
            // List of sessions
            if (_schedules.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final item = _schedules[index];
                  final name = item['name'] ?? 'Không tên';
                  final description = item['description'] ?? '';
                  final startDate = item['startDate'] ?? '';
                  final endDate = item['endDate'] ?? '';
                  final id = item['id'].toString();
                  final dtStart = startDate.isNotEmpty ? DateTime.parse(startDate) : null;
                  final dtEnd = endDate.isNotEmpty ? DateTime.parse(endDate) : null;
                  final formattedDate = dtStart != null
                      ? '${dtStart.day} thg ${dtStart.month}'
                      : '';
                  final formattedTime = dtStart != null
                      ? DateFormat('HH:mm').format(dtStart)
                      : '';
                  final activityCount = _activityCounts[id] ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ngày bắt đầu nằm trên khung, định dạng dd thg mm
                      if (formattedDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_note,
                                      color: Colors.deepPurple),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.deepPurple),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                  const SizedBox(width: 6),
                                  Text('$activityCount hoạt động',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
