import 'package:pet_tracker/features/home/domain/entities/current_location.dart';

abstract class CurrentLocationDatasource {
  Stream<CurrentLocation> connectToCurrentLocationStream(String roomId);
}
