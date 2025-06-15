// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/devices/domain/entities/device.dart';
import 'package:pet_tracker/features/devices/infrastructure/infrastructure.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class DeviceNotifier extends StateNotifier<AsyncValue<List<Device>>> {
  final DeviceRepositoryImpl repository;
  final KeyValueStorageService storageService;

  DeviceNotifier({
    required this.repository,
    required this.storageService,
  }) : super(const AsyncLoading());

  Future<void> fetchDevices(String userId) async {
    try {
      final devices = await repository.getAllDevices(userId);
      state = AsyncValue.data(devices);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> selectDevice(Device device) async {
    try {
      await storageService.setKeyValue<String>(
          'selectedDeviceRecordId', device.petTrackerDeviceRecordId);
      await storageService.setKeyValue<String>(
          'selectedApiKey', device.apiKey);
    } catch (e) {
      print("Error al seleccionar el dispositivo: $e");
    }
  }

  Future<String?> getSelectedDeviceId() async {
    return await storageService.getValue<String>('selectedDeviceRecordId');
  }

  Future<void> updateDevice(Device device, String bearer, String deviceNickname,
      String deviceCareModes, String deviceStatuses) async {
    try {
      final updatedDevice = await repository.updateDevice(
        bearer,
        deviceNickname,
        deviceCareModes,
        deviceStatuses,
        device.petTrackerDeviceRecordId,
      );

      state = state.whenData((devices) {
        return devices
            .map((d) =>
                d.petTrackerDeviceRecordId == updatedDevice.petTrackerDeviceRecordId
                    ? updatedDevice
                    : d)
            .toList();
      });
    } catch (e, stackTrace) {
      print("Error al actualizar el dispositivo: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

class DeviceAssignNotifier extends StateNotifier<AsyncValue<void>> {
  final DeviceRepositoryImpl repository;
  final KeyValueStorageService storageService;

  DeviceAssignNotifier({
    required this.repository,
    required this.storageService,
  }) : super(const AsyncData(null));

  Future<void> assignDeviceToUser(
      BuildContext context, String deviceRecordId, String userId) async {
    state = const AsyncValue.loading();

    // >>> LOG importante
    print('>>> Intentando asignar deviceRecordId: $deviceRecordId a userId: $userId');

    try {
      final assignedDevice =
          await repository.assignDeviceToUser(deviceRecordId, userId);

      // Guardar valores en storage
      await storageService.setKeyValue<String>(
          'selectedDeviceRecordId', assignedDevice.petTrackerDeviceRecordId);
      await storageService.setKeyValue<String>(
          'selectedApiKey', assignedDevice.apiKey);

      print('>>> Asignación exitosa del dispositivo');
      print('>>> selectedDeviceRecordId guardado: ${assignedDevice.petTrackerDeviceRecordId}');
      print('>>> selectedApiKey guardado: ${assignedDevice.apiKey}');

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      state = const AsyncValue.data(null);
    } on DioException catch (e, stackTrace) {
      final errorMessage =
          e.response?.data?['message'] ?? 'Device not found (DioException)';

      print('>>> DioException al asignar: $errorMessage');
      print('>>> DioResponse: ${e.response}');

      state = AsyncValue.error(errorMessage, stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stackTrace) {
      print('>>> Error inesperado al asignar: $e');
      state = AsyncValue.error(e, stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

final deviceRepositoryProvider = Provider<DeviceRepositoryImpl>((ref) {
  final datasource = ref.watch(deviceDatasourceProvider);
  return DeviceRepositoryImpl(datasource);
});

final deviceDatasourceProvider = Provider<DeviceDatasourceImpl>((ref) {
  return DeviceDatasourceImpl(
    storageService: ref.watch(keyValueStorageServiceProvider),
  );
});

final deviceProvider = StateNotifierProvider.family<DeviceNotifier,
    AsyncValue<List<Device>>, String>(
  (ref, userId) {
    final repository = ref.watch(deviceRepositoryProvider);
    final storageService = ref.watch(keyValueStorageServiceProvider);

    final notifier = DeviceNotifier(
      repository: repository,
      storageService: storageService,
    );

    notifier.fetchDevices(userId);
    return notifier;
  },
);

final deviceAssignProvider =
    StateNotifierProvider<DeviceAssignNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.watch(deviceRepositoryProvider);
    final storageService = ref.watch(keyValueStorageServiceProvider);
    return DeviceAssignNotifier(
      repository: repository,
      storageService: storageService,
    );
  },
);
