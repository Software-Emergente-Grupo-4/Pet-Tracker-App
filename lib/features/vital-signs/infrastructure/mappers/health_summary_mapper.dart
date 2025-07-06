import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';

class HealthSummaryMapper {
  static HealthSummary fromJson(Map<String, dynamic> json) {
    return HealthSummary(date: DateTime.parse(json['date']), avgBpm: (json['avgBpm'] as num).toInt(), avgSpo2: (json['avgSpo2'] as num).toInt());
  }
}