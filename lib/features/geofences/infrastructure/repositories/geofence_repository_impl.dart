import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';
import 'package:pet_tracker/features/geofences/domain/repositories/geofence_repository.dart';
import 'package:pet_tracker/features/geofences/domain/datasources/geofence_datasource.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  final GeofenceDatasource datasource;

  GeofenceRepositoryImpl({required this.datasource});

  @override
  Future<Geofence> createGeofence(Geofence geofence) async {
    return await datasource.createGeofence(geofence);
  }

  @override
  Future<List<Geofence>> fetchGeofences(selectedDeviceRecordId) async {
    return await datasource.fetchGeofences(selectedDeviceRecordId);
  }

  @override
  Future<Geofence> updateGeofence(Geofence geofence) async {
    return  await datasource.updateGeofence(geofence);
  }
}
