import 'package:pet_tracker/features/navigation/domain/datasources/health_stream_datasource.dart';
import 'package:pet_tracker/features/navigation/domain/entities/health_measure.dart';
import 'package:pet_tracker/features/navigation/domain/repositories/health_stream_repository.dart';

class HealthStreamRepositoryImpl extends HealthStreamRepository {
  final HealthStreamDatasource datasource;

  HealthStreamRepositoryImpl({required this.datasource});

  @override
  Stream<HealthMeasure> getHealthStream(String roomId) {
    return datasource.connectToHealthStream(roomId);
  }
}
