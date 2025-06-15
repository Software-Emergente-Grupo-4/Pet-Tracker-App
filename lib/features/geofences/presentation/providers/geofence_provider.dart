import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';
import 'package:pet_tracker/features/geofences/domain/repositories/geofence_repository.dart';
import 'package:pet_tracker/features/geofences/presentation/providers/geofence_repository_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_service.dart';
import 'package:pet_tracker/features/devices/presentation/providers/device_provider.dart';
import 'package:pet_tracker/features/devices/infrastructure/repositories/device_repository_impl.dart';

class GeofenceState {
  final List<Geofence> geofences;
  final bool isLoading;
  final String? errorMessage;

  GeofenceState({
    this.geofences = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GeofenceState copyWith({
    List<Geofence>? geofences,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GeofenceState(
      geofences: geofences ?? this.geofences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class GeofenceNotifier extends StateNotifier<GeofenceState> {
  final GeofenceRepository repository;
  final KeyValueStorageService storageService;
  final DeviceRepositoryImpl deviceRepository;

  GeofenceNotifier(
    this.repository,
    this.storageService,
    this.deviceRepository,
  ) : super(GeofenceState()) {
    loadGeofences();
  }

  Future<void> loadGeofences() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = await storageService.getValue<String>('userId');
      var selectedDeviceRecordId =
          await storageService.getValue<String>('selectedDeviceRecordId');

      if (userId == null) {
        throw Exception('No user found');
      }

      final userDevices = await deviceRepository.getAllDevices(userId);

      // 🧹 Limpiar todo si el usuario no tiene dispositivos
      if (userDevices.isEmpty) {
        await storageService.removeKey('selectedDeviceRecordId');
        state = state.copyWith(
          geofences: [],
          isLoading: false,
          errorMessage: 'No devices assigned to this user.',
        );
        return;
      }

      // ✅ Si no hay dispositivo seleccionado, asignamos uno por defecto
      if (selectedDeviceRecordId == null) {
        selectedDeviceRecordId = userDevices.first.petTrackerDeviceRecordId;
        await storageService.setKeyValue<String>(
            'selectedDeviceRecordId', selectedDeviceRecordId);
      }

      final isOwnedDevice = userDevices.any(
        (device) =>
            device.petTrackerDeviceRecordId == selectedDeviceRecordId,
      );

      if (!isOwnedDevice) {
        throw Exception('Unauthorized access to device geofences');
      }

      final geofences =
          await repository.fetchGeofences(selectedDeviceRecordId);
      state = state.copyWith(geofences: geofences, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> addGeofence(Geofence geofence) async {
    try {
      await repository.createGeofence(geofence);
      await loadGeofences();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateGeofence(Geofence geofence) async {
    try {
      await repository.updateGeofence(geofence);
      await loadGeofences();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final geofenceProvider =
    StateNotifierProvider<GeofenceNotifier, GeofenceState>((ref) {
  final repository = ref.read(geofenceRepositoryProvider);
  final storageService = ref.watch(keyValueStorageServiceProvider);
  final deviceRepository = ref.read(deviceRepositoryProvider);
  return GeofenceNotifier(repository, storageService, deviceRepository);
});
