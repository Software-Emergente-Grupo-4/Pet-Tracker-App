import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';

class Spo2ChartWidget extends StatelessWidget {
  final List<HealthSummary> data;

  const Spo2ChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bpmData = data
        .map((e) => FlSpot(
              e.date.millisecondsSinceEpoch.toDouble(),
              e.avgSpo2.toDouble(),
            ))
        .toList();

    final month =
        data.isNotEmpty ? data.first.date.month : DateTime.now().month;
    final monthName = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][month - 1];
    final year = data.isNotEmpty ? data.first.date.year : DateTime.now().year;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Text(
                '$monthName $year',
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    minY: 90,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: bpmData,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1 * 86400000,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Text('${date.day}');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                value.toInt().toString(),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
