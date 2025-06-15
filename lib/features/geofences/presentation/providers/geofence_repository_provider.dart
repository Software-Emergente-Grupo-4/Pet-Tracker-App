import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/geofences/infrastructure/datasources/geofence_datasource_impl.dart';
import 'package:pet_tracker/features/geofences/infrastructure/repositories/geofence_repository_impl.dart';
import 'package:pet_tracker/features/geofences/domain/repositories/geofence_repository.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

// Proveedor para el datasource
final geofenceDatasourceProvider = Provider<GeofenceDatasourceImpl>((ref) {
  final storageService = ref.read(keyValueStorageServiceProvider);
  final dio = ref.read(dioProvider);
  return GeofenceDatasourceImpl(storageService: storageService, dio: dio);
});

// Proveedor para el repositorio
final geofenceRepositoryProvider = Provider<GeofenceRepository>((ref) {
  final datasource = ref.read(geofenceDatasourceProvider);
  return GeofenceRepositoryImpl(datasource: datasource);
});
