import 'package:pet_tracker/features/navigation/domain/entities/health_measure.dart';

abstract class HealthStreamDatasource {
  Stream<HealthMeasure> connectToHealthStream(String roomId);
}
