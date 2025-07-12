import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pe_emoease_mobileapp_flutter/services/schedule_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Constants
  static const List<String> _weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
  static const List<String> _dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  
  // State variables
  String _selectedWeek = 'Week 1';
  bool _loading = true;
  List<Map<String, dynamic>> _totalSessions = [];
  
  // Services
  final _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    
    try {
      final schedulesData = await _scheduleService.fetchSchedules(
        pageIndex: 1,
        pageSize: 10,
      );
      
      if (schedulesData['data'] != null && schedulesData['data'].isNotEmpty) {
        final firstSchedule = schedulesData['data'][0];
        final scheduleId = firstSchedule['id'];
        final startDate = firstSchedule['startDate'].substring(0, 10);
        final endDate = firstSchedule['endDate'].substring(0, 10);
        
        final sessionsData = await _scheduleService.fetchTotalSessions(
          scheduleId: scheduleId,
          startDate: startDate,
          endDate: endDate,
        );
        
        setState(() {
          _totalSessions = List<Map<String, dynamic>>.from(sessionsData['sessions'] ?? []);
          _loading = false;
        });
      } else {
        setState(() {
          _totalSessions = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }



  List<Map<String, dynamic>> get _chartData {
    if (_totalSessions.isEmpty) return [];
    
    final weekIndex = _weeks.indexOf(_selectedWeek);
    final startIndex = weekIndex * 7;
    final weekData = _totalSessions.skip(startIndex).take(7).toList();
    
    return weekData.asMap().entries.map((entry) {
      final index = entry.key;
      final session = entry.value;
      final date = DateTime.parse(session['order']);
      
      return {
        'id': session['sessionId'],
        'day': _dayNames[date.weekday % 7],
        'date': '${date.day}/${date.month}',
        'fullDate': session['order'],
        'percentage': (session['percentage'] as num).round(),
        'x': index.toDouble(),
      };
    }).toList();
  }

  Map<String, dynamic> get _stats {
    if (_chartData.isEmpty) {
      return {'completed': 0, 'total': 0, 'average': 0, 'bestDay': null};
    }
    
    final completed = _chartData.where((item) => item['percentage'] > 0).length;
    final total = _chartData.length;
    final average = _chartData.fold<int>(0, (sum, item) => sum + (item['percentage'] as int)) ~/ total;
    final bestDay = _chartData.reduce((max, item) => 
      item['percentage'] > max['percentage'] ? item : max);
    
    return {'completed': completed, 'total': total, 'average': average, 'bestDay': bestDay};
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBestDayCard(),
              const SizedBox(height: 24),
              _buildWeeklyProgressCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu...'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildChart(),
          const SizedBox(height: 20),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tiến độ tuần',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Hoàn thành hoạt động hàng ngày',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        _buildWeekSelector(),
      ],
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedWeek,
        items: _weeks.map((week) => DropdownMenuItem(value: week, child: Text(week))).toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedWeek = value);
        },
        style: const TextStyle(
          fontSize: 16,
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildChart() {
    if (_chartData.isEmpty) {
      return _buildEmptyChart();
    }
    
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: 100,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              left: BorderSide(color: Colors.transparent, width: 0),
              right: BorderSide(color: Colors.transparent, width: 0),
            ),
          ),
          titlesData: _buildChartTitles(),
          barGroups: _buildBarGroups(),
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles() {
    return FlTitlesData(
      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= _chartData.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${_chartData[index]['percentage']}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            );
          },
          reservedSize: 28,
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 25,
          getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 12)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= _chartData.length) return const SizedBox.shrink();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_chartData[index]['day'], style: const TextStyle(fontSize: 12)),
                Text(_chartData[index]['date'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item['percentage'].toDouble(),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.deepPurple.shade100],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Không có dữ liệu cho tuần này', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.check_circle, 'Hoàn thành', _stats['completed'].toString()),
        _buildStatItem(Icons.calendar_today, 'Tổng phiên', _stats['total'].toString()),
        _buildStatItem(Icons.trending_up, 'Trung bình', '${_stats['average']}%', isHighlighted: true),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, {bool isHighlighted = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHighlighted ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isHighlighted ? Colors.deepPurple : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.deepPurple : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestDayCard() {
    final bestDay = _stats['bestDay'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngày xuất sắc nhất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepPurple.shade700),
                ),
                const SizedBox(height: 4),
                if (bestDay != null) ...[
                  Text(
                    '${bestDay['day']}, ${bestDay['date']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ] else ...[
                  Text(
                    'Chưa có dữ liệu',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          if (bestDay != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${bestDay['percentage']}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '--',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
