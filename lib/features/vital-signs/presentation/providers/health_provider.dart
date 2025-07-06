import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/datasource/health_datasource_impl.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/repositories/health_repository_impl.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

final healthProvider = FutureProvider.autoDispose<List<Health>>((ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  final storageService = ref.read(keyValueStorageServiceProvider);

  final deviceRecordId =
      await storageService.getValue<String>('selectedDeviceRecordId');
  if (deviceRecordId == null) {
    throw Exception('Device ID not found');
  }

  return await repository.getHealthData(deviceRecordId);
});

final healthRepositoryProvider = Provider((ref) {
  final healthDatasource = HealthDatasourceImpl(
      storageService: ref.read(keyValueStorageServiceProvider));
  return HealthRepositoryImpl(healthDatasource);
});
