import 'package:pet_tracker/features/vital-signs/domain/entities/health.dart';

abstract class HealthDatasource {
  Future<List<Health>> getHealthData(String deviceRecordId);
}
