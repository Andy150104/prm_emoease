import 'package:flutter/material.dart';
import '../services/schedule_service.dart';

class ScheduleDetailPage extends StatefulWidget {
  final String sessionId;
  final String sessionDate;

  const ScheduleDetailPage({
    Key? key,
    required this.sessionId,
    required this.sessionDate,
  }) : super(key: key);

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  final ScheduleService _service = ScheduleService();
  bool _loading = true;
  List<dynamic> _activities = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => _loading = true);
    try {
      final res = await _service.fetchActivities(widget.sessionId);
      setState(() {
        _activities = res['items'] ?? res['activities'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy hoạt động: $e')),
      );
    }
  }

  Future<void> _toggleActivityStatus(String id, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'Completed' ? 'Pending' : 'Completed';
      await _service.updateActivityStatus(
        taskId: id,
        sessionsForDate: widget.sessionId,
        newStatus: newStatus,
      );

      await _fetchActivities(); // refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text('Phiên ${widget.sessionDate}'),
        backgroundColor: purple,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _activities.isEmpty
            ? const Center(child: Text('Không có hoạt động nào'))
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: _activities.length,
          itemBuilder: (context, i) {
            final act = _activities[i];
            final title = act['title'] ??
                act['entertainmentActivity']?['name'] ??
                act['foodActivity']?['name'] ??
                act['physicalActivity']?['name'] ??
                act['therapeuticActivity']?['name'] ??
                'Hoạt động';
            final desc = act['description'] ?? '';
            final completed = act['status'] == 'Completed';

            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: completed
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
              ),
              title: Text(title,
                  style:
                  const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(desc),
              trailing: Text(
                completed ? 'Hoàn thành' : 'Chưa',
                style: TextStyle(
                  color: completed
                      ? Colors.green
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _toggleActivityStatus(act['id'], act['status']);
              },
            );
          },
        ),
      ),
    );
  }
}
