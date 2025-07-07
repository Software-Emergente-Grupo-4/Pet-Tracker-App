import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pet_tracker/features/geofences/infrastructure/datasources/geofence_datasource_impl.dart';
import 'package:pet_tracker/features/geofences/infrastructure/repositories/geofence_repository_impl.dart';
import 'package:pet_tracker/features/geofences/domain/repositories/geofence_repository.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

// Proveedor para el datasource
final geofenceDatasourceProvider = Provider<GeofenceDatasourceImpl>((ref) {
  final dio = Dio();
  final storageService = ref.read(keyValueStorageServiceProvider);
  return GeofenceDatasourceImpl(storageService: storageService, dio: dio);
});

// Proveedor para el repositorio
final geofenceRepositoryProvider = Provider<GeofenceRepository>((ref) {
  final datasource = ref.read(geofenceDatasourceProvider);
  return GeofenceRepositoryImpl(datasource: datasource);
});
