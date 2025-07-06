import 'package:pet_tracker/features/home/domain/entities/current_location.dart';

abstract class CurrentLocationRepository {
  Stream<CurrentLocation> connectToCurrentLocationStream(String roomId);
}
