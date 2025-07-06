import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_summary_provider.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/bpm_chart.dart';
import 'package:pet_tracker/features/vital-signs/presentation/widgets/spo2_chart.dart';

class HealthSummaryScreen extends ConsumerStatefulWidget {
  const HealthSummaryScreen({super.key});
  @override
  ConsumerState<HealthSummaryScreen> createState() => _HealthSummaryScreenState();
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

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null) return Text(state.errorMessage!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signos Vitales'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BPM'),
            Tab(text: 'Saturación'),
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
              child: BpmChartWidget(data: state.summaries),
            ),
          ),

          // Tab 2: Saturación (placeholder con misma lógica)
          RefreshIndicator(
            onRefresh: () async {
              await notifier.loadSummaries();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Spo2ChartWidget(data: state.summaries),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
