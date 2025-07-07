import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/devices/infrastructure/repositories/device_repository_impl.dart';
import 'package:pet_tracker/features/devices/presentation/providers/device_provider.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';
import 'package:pet_tracker/features/vital-signs/domain/repositories/health_summary_repository.dart';
import 'package:pet_tracker/features/vital-signs/presentation/providers/health_summary_repository_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class HealthSummaryState {
  final bool isLoading;
  final String? errorMessage;
  final List<HealthSummary> summaries;

  HealthSummaryState({
    this.isLoading = false,
    this.errorMessage,
    this.summaries = const [],
  });

  HealthSummaryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<HealthSummary>? summaries,
  }) {
    return HealthSummaryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      summaries: summaries ?? this.summaries,
    );
  }
}

class HealthSummaryNotifier extends StateNotifier<HealthSummaryState> {
  final HealthSummaryRepository repository;
  final KeyValueStorageService storageService;
  final DeviceRepositoryImpl deviceRepository;

  HealthSummaryNotifier(
      this.repository, this.storageService, this.deviceRepository)
      : super(HealthSummaryState()) {
    loadSummaries();
  }

  Future<void> loadSummaries() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = await storageService.getValue<String>('userId');
      var selectedDeviceRecordId =
          await storageService.getValue<String>('selectedDeviceRecordId');

      if (userId == null) {
        throw Exception('No user found');
      }

      final userDevices = await deviceRepository.getAllDevices(userId);

      if (userDevices.isEmpty) {
        await storageService.removeKey('selectedDeviceRecordId');
        state = state.copyWith(
          summaries: [],
          isLoading: false,
          errorMessage: 'No devices assigned to this user.',
        );
        return;
      }

      if (selectedDeviceRecordId == null) {
        selectedDeviceRecordId = userDevices.first.petTrackerDeviceRecordId;
        await storageService.setKeyValue<String>(
            'selectedDeviceRecordId', selectedDeviceRecordId);
      }

      final isOwnedDevice = userDevices.any(
        (device) => device.petTrackerDeviceRecordId == selectedDeviceRecordId,
      );

      if (!isOwnedDevice) {
        throw Exception('Unauthorized access');
      }

      final data = await repository.fetchHealthSummary(selectedDeviceRecordId);
      state = state.copyWith(summaries: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// Provider
final healthSummaryProvider =
    StateNotifierProvider<HealthSummaryNotifier, HealthSummaryState>((ref) {
  final repository = ref.read(healthSummaryRepositoryProvider);
  final storageService = ref.read(keyValueStorageServiceProvider);
  final deviceRepository = ref.read(deviceRepositoryProvider);

  return HealthSummaryNotifier(repository, storageService, deviceRepository);
});
