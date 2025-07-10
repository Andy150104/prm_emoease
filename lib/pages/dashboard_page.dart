import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedWeek = 'Week 1';
  final List<String> weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Best Day Card (Enhanced Samsung One UI Style)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ngày xuất sắc nhất',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Thành tích cao nhất trong tuần',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '15/6',
                            style: TextStyle(                            
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'CN',
                            style: TextStyle(
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      
                      Text(
                        '86%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          shadows: [
                            Shadow(
                              color: Colors.deepPurple.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiến độ tuần',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hoàn thành hoạt động trong ngày',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F3F5), // Samsung One UI light grey
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButton<String>(
                              value: selectedWeek,
                              items: weeks.map((week) {
                                return DropdownMenuItem<String>(
                                  value: week,
                                  child: Text(week),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedWeek = value;
                                  });
                                }
                              },
                              style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                              underline: SizedBox.shrink(), // Remove default underline
                              iconEnabledColor: Colors.deepPurple,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final moodPercentages = [70, 85, 50, 90, 40, 60, 75];
                        final barCount = moodPercentages.length;
                        final barSpacing = constraints.maxWidth / barCount;

                        return Stack(
                          children: [
                            // The actual chart
                            BarChart(
                              BarChartData(
                                maxY: 100, // Allow space for labels
                                minY: 0,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false, // Only show horizontal lines
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade300,
                                      strokeWidth: 1, // Solid line
                                      dashArray: null, // Ensures solid line
                                    );
                                  },
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
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final moodPercentages = [70, 85, 50, 90, 40, 60, 75];
                                        final index = value.toInt();
                                        if (index < 0 || index >= moodPercentages.length) return const SizedBox.shrink();

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            '${moodPercentages[index]}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
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
                                      getTitlesWidget: (value, _) =>
                                          Text('${value.toInt()}%', style: const TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (value, meta) {
                                        final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                        final dates = ['11/6', '12/6', '13/6', '14/6', '15/6', '16/6', '17/6'];
                                        final index = value.toInt();
                                        if (index < 0 || index >= days.length) return const SizedBox.shrink();
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(days[index], style: const TextStyle(fontSize: 12)),
                                            Text(dates[index], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                barGroups: List.generate(barCount, (i) {
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: moodPercentages[i].toDouble(),
                                        width: 20,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.deepPurple,
                                            Colors.deepPurple.shade100,
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),

                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                 // Summary row: Hoàn thành (Completion), Tổng phiên (Total Sessions), Trung bình (Average)
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     // Hoàn thành (Completion)
                     Expanded(
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: const [
                           Icon(Icons.check_circle, color: Colors.deepPurple, size: 28),
                           SizedBox(height: 4),
                           Text('Hoàn thành', style: TextStyle(fontSize: 14)),
                           SizedBox(height: 2),
                           Text('7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         ],
                       ),
                     ),
                     // Tổng phiên (Total Sessions)
                     Expanded(
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: const [
                           Icon(Icons.calendar_today, color: Colors.deepPurple, size: 28),
                           SizedBox(height: 4),
                           Text('Tổng phiên', style: TextStyle(fontSize: 14)),
                           SizedBox(height: 2),
                           Text('7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         ],
                       ),
                     ),
                     // Trung bình (Average)
                     Expanded(
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: const [
                           Icon(Icons.show_chart, color: Colors.deepPurple, size: 28),
                           SizedBox(height: 4),
                           Text('Trung bình', style: TextStyle(fontSize: 14)),
                           SizedBox(height: 2),
                           Text('33%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         ],
                       ),
                     ),
                   ],
                 ),
                ],
              ),
            ),
            
            
          ],
        ),
      ),

    );
  }
}
