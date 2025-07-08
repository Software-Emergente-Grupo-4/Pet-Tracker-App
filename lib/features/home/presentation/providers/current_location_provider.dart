import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/home/domain/entities/current_location.dart';
import 'package:pet_tracker/features/home/infrastructure/datasources/current_location_datasource_impl.dart';
import 'package:pet_tracker/features/home/infrastructure/repositories/current_location_repository_impl.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';

final currentLocationProvider =
    StreamProvider.autoDispose<CurrentLocation>((ref) async* {
  final repository = ref.watch(currentLocationRepositoryProvider);
  final storageService = ref.watch(keyValueStorageServiceProvider);

  try {
    final roomId = await storageService.getValue<String>('selectedApiKey');
    if (roomId == null || roomId.isEmpty) {
      throw Exception('Room ID (selectedApiKey) is not available.');
    }

    yield* repository.connectToCurrentLocationStream(roomId);
  } catch (error) {
    throw Exception('Error connecting to current location stream: $error');
  }
});

final currentLocationRepositoryProvider =
    Provider<CurrentLocationRepositoryImpl>((ref) {
  final datasource = CurrentLocationDatasourceImpl();
  return CurrentLocationRepositoryImpl(datasource: datasource);
});
