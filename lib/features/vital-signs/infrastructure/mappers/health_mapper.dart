import 'package:pet_tracker/features/vital-signs/domain/entities/health.dart';

class HealthMapper {
  static List<Health> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return Health(
        date: DateTime.parse(json['date']),
        avgBpm: json['avgBpm'] as double,
        avgSpo2: json['avgSpo2'] as double,
      );
    }).toList();
  }
}
