// prediction_result_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';

class PredictionResultScreen extends StatelessWidget {
  final String dataType; // 'bpm' o 'spo2'
  final List<HealthSummary> predictions;

  const PredictionResultScreen({
    super.key,
    required this.dataType,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    final month = predictions.isNotEmpty
        ? predictions.first.date.month
        : DateTime.now().month;
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
    final year = predictions.isNotEmpty
        ? predictions.first.date.year
        : DateTime.now().year;
    final spots = predictions.map((e) {
      final date = e.date;
      final value = dataType == 'bpm' ? e.avgBpm : e.avgSpo2;
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), value.toDouble());
    }).toList();

    final title = dataType == 'bpm' ? 'Predicted Heart Rate' : 'Predicted SpO₂';
    final color = dataType == 'bpm' ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
          title: Text(title,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('$monthName $year',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: predictions.isEmpty
                  ? Text(
                      'There is not enough data to generate the $title for the next month')
                  : LineChart(
                      LineChartData(
                        minY: dataType == 'bpm' ? 45 : 90,
                        maxY: dataType == 'bpm' ? 200 : 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: color,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withOpacity(0.2),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 3 * 86400000,
                              getTitlesWidget: (value, meta) {
                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
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
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
                'These predictions are generated using machine learning models trained on your pet’s data.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
