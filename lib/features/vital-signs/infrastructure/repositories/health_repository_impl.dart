import 'package:pet_tracker/features/vital-signs/domain/datasource/health_datasource.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health.dart';
import 'package:pet_tracker/features/vital-signs/domain/repositories/health_repository.dart';

class HealthRepositoryImpl extends HealthRepository {
  final HealthDatasource datasource;

  HealthRepositoryImpl(this.datasource);

  @override
  Future<List<Health>> getHealthData(String deviceRecordId) {
    return datasource.getHealthData(deviceRecordId);
  }
}
