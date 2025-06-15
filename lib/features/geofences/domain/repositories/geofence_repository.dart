import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';

abstract class GeofenceRepository {
  Future<Geofence> createGeofence(Geofence geofence);
  Future<List<Geofence>> fetchGeofences(String selectedDeviceRecordId);
  Future<Geofence> updateGeofence(Geofence geofence);
}
