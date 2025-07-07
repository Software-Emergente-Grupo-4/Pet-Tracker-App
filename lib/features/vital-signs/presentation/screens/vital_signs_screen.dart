import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_summary_provider.dart';
import 'package:pet_tracker/features/vital-signs/presentation/screens/prediction_loading_screen.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_tips_list.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/prediction_button.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_tips_list.dart';

class HealthSummaryScreen extends ConsumerStatefulWidget {
  const HealthSummaryScreen({super.key});
  @override
  ConsumerState<HealthSummaryScreen> createState() =>
      _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends ConsumerState<HealthSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthSummaryProvider);
    final notifier = ref.read(healthSummaryProvider.notifier);

    if (state.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null) return Text(state.errorMessage!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Health Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Heart Rate (BPM)'),
            Tab(text: 'Saturation (SpO2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: BPM
          RefreshIndicator(
            onRefresh: () async {
              await notifier.loadSummaries();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  BpmChartWidget(data: state.summaries),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PredictButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PredictionLoadingScreen(
                                dataType: 'bpm',
                                repository: notifier.repository,
                                storageService: notifier.storageService,
                                deviceRepository: notifier.deviceRepository),
                          ),
                        );
                      },
                    ),
                  ),
                  const BpmTipsListWidget()
                ],
              ),
            ),
          ),

          // Tab 2: SpO2
          RefreshIndicator(
            onRefresh: () async {
              await notifier.loadSummaries();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Spo2ChartWidget(data: state.summaries),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PredictButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PredictionLoadingScreen(
                                dataType: 'spo2',
                                repository: notifier.repository,
                                storageService: notifier.storageService,
                                deviceRepository: notifier.deviceRepository),
                          ),
                        );
                      },
                    ),
                  ),
                  const Spo2TipsListWidget()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
