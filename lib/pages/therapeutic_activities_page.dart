import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/services/lifestyle_service.dart';
import 'package:pe_emoease_mobileapp_flutter/services/profile_service.dart';

class cPage extends StatefulWidget {
  const TherapeuticActivitiesPage({Key? key}) : super(key: key);

  @override
  State<TherapeuticActivitiesPage> createState() => _TherapeuticActivitiesPageState();
}

class _TherapeuticActivitiesPageState extends State<TherapeuticActivitiesPage> {
  final LifestyleService _service = LifestyleService();
  bool _loading = true;
  List<dynamic> _activities = [];
  Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final data = await _service.fetchTherapeuticActivities();
    setState(() {
      _activities = data;
      _loading = false;
    });
  }

  IconData getActivityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('nhận thức')) return Icons.psychology_alt;
    if (lower.contains('hít thở')) return Icons.air;
    if (lower.contains('viết nhật ký') && lower.contains('biểu cảm')) return Icons.edit_note;
    if (lower.contains('viết nhật ký') && lower.contains('biết ơn')) return Icons.favorite;
    if (lower.contains('thiền') && lower.contains('hướng dẫn')) return Icons.self_improvement;
    if (lower.contains('thiền') && lower.contains('chánh niệm')) return Icons.spa;
    if (lower.contains('thư giãn cơ bắp')) return Icons.accessibility_new;
    if (lower.contains('tái cấu trúc')) return Icons.change_circle;
    return Icons.spa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoạt động trị liệu')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade800, // darker for contrast
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tiến độ của bạn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('${_selectedIndexes.length}/${_activities.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _activities.isEmpty ? 0 : _selectedIndexes.length / _activities.length,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent.shade400),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tuyệt vời! Bạn đã chọn ${_selectedIndexes.length} hoạt động',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      final icon = getActivityIcon(activity['name'] ?? '');
                      final color = Colors.deepPurple.shade100;
                      Color getLevelColor(String? level) {
                        switch (level) {
                          case 'Thấp': return Colors.green;
                          case 'Trung bình': return Colors.orange;
                          case 'Cao': return Colors.red;
                          case 'Rất cao': return Colors.purple;
                          default: return Colors.grey;
                        }
                      }
                      final isSelected = _selectedIndexes.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndexes.remove(index);
                            } else {
                              _selectedIndexes.add(index);
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? Colors.deepPurple : Colors.deepPurple.shade100,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(icon, color: Colors.deepPurple, size: 32),
                                    ),
                                    const SizedBox(height: 12),
                                    Flexible(
                                      child: Text(
                                        activity['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.favorite, color: Colors.red, size: 16),
                                            SizedBox(width: 4),
                                            Text('Yêu thích', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(
                                            color: getLevelColor(activity['intensityLevel']),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(activity['intensityLevel'] ?? '', style: const TextStyle(fontSize: 12)),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(
                                            color: getLevelColor(activity['impactLevel']),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(activity['impactLevel'] ?? '', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _selectedIndexes.isEmpty ? null : () async {
                        setState(() => _loading = true);
                        try {
                          final patientProfileId = await ProfileService.getPatientProfileIdFromToken();
                          final selected = _selectedIndexes.map((i) => {
                            'therapeuticActivityId': _activities[i]['id'],
                            'preferenceLevel': 'Daily',
                          }).toList();
                          await _service.savePatientTherapeuticActivities(patientProfileId, selected);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!')));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                      child: Text(
                        'Tiếp tục với ${_selectedIndexes.length} hoạt động',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
