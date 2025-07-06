import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class VitalSignsScreen extends ConsumerWidget {
  const VitalSignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthDataAsync = ref.watch(healthProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Health Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                isScrollable: false,
                dividerColor: Color(0xFF08273A),
                dividerHeight: 2,
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF08273A),
                indicator: BoxDecoration(
                  color: Color(0xFF08273A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                tabs: [
                  Tab(
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text('Heart Rate'),
                      ),
                    ),
                  ),
                  Tab(
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text('Oxygenation'),
                      ),
                    ),
                  ),
                ],
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: healthDataAsync.when(
          data: (healthData) => TabBarView(
            children: [
              _buildChart(healthData, isHeartRate: true),
              _buildChart(healthData, isHeartRate: false),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/chart-simple-solid.svg',
                  width: 50,
                  height: 50,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                const Text(
                  'If you don\'t see the map, please check if you have selected a device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF08273A),
                      fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<Health> data, {required bool isHeartRate}) {
    final dayLabels = data
        .map((e) =>
            "${DateFormat('EEE').format(e.date)}\n${DateFormat('dd').format(e.date)}")
        .toList();

    final values = isHeartRate
        ? data.map((e) => e.avgBpm).toList()
        : data.map((e) => e.avgSpo2).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolution of ${isHeartRate ? "Heart Rate" : "Oxygenation"} during the days of the month',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (values.length - 1).toDouble(),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        "Days of the month",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: values.length > 5
                          ? (values.length / 5).floorToDouble()
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dayLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              dayLabels[index],
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, reservedSize: 48, interval: 10.0),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: values
                        .asMap()
                        .entries
                        .map((entry) =>
                            FlSpot(entry.key.toDouble(), entry.value))
                        .toList(),
                    isCurved: false,
                    dotData: const FlDotData(show: true),
                    color: const Color(0xFF1E88E5),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E88E5).withOpacity(1),
                          const Color(0xFF64B5F6).withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: _buildTips(isHeartRate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips(bool isHeartRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips according to ${isHeartRate ? 'Heart Rate' : 'Oxygenation'}:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ..._getTips(isHeartRate),
      ],
    );
  }

  List<Widget> _getTips(bool isHeartRate) {
    final tips = isHeartRate
        ? [
            "70-80 bpm: Indicates a normal heart rate. Continue with your usual activities and maintain a balanced diet.",
            "81-90 bpm: A slight increase in heart rate. It may be beneficial to perform relaxation exercises or meditation.",
            "91-100 bpm: High heart rate. Consider consulting a healthcare professional for a more detailed evaluation.",
          ]
        : [
            "95-100%: Normal oxygen level. There are no worries. Continue with your usual activities and stay hydrated.",
            "91-94%: Slight decrease in oxygen levels. It may be helpful to rest and breathe fresh air. If levels remain low, it is advisable to consult a health professional.",
            "Less than 90%: Hypoxemia. Low oxygen level which may indicate a significant health problem. It is necessary to consult a doctor immediately or go to a healthcare facility.",
          ];

    return tips
        .map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F7FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF47A1DE),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
