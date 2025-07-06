import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/vital-signs/domain/repositories/health_summary_repository.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/datasources/health_summary_datasource_impl.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/repositories/health_summary_repository_impl.dart';

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
final healthSummaryDatasourceProvider = Provider<HealthSummaryDatasourceImpl>((ref) {
  final storageService = ref.read(keyValueStorageServiceProvider);
  final dio = ref.read(dioProvider);
  return HealthSummaryDatasourceImpl(storageService: storageService, dio: dio);
});

// Proveedor para el repositorio
final healthSummaryRepositoryProvider = Provider<HealthSummaryRepository>((ref) {
  final datasource = ref.read(healthSummaryDatasourceProvider);
  return HealthSummaryRepositoryImpl(remoteDataSource: datasource);
});