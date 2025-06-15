import 'package:pet_tracker/features/devices/domain/entities/device.dart';
import 'package:pet_tracker/features/devices/domain/repositories/device_repository.dart';
import 'package:pet_tracker/features/devices/infrastructure/datasources/device_datasource_impl.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  final DeviceDatasourceImpl datasource;

  DeviceRepositoryImpl(this.datasource);

  @override
  Future<Device> assignDeviceToUser(String deviceRecordId, String userId) {
    return datasource.assignDeviceToUser(deviceRecordId, userId);
  }

  @override
  Future<List<Device>> getAllDevices(String userId) {
    return datasource.getAllDevices(userId);
  }

  @override
  Future<Device> updateDevice(
    String bearer,
    String deviceNickname,
    String deviceCareModes,
    String deviceStatuses,
    String deviceRecordId,
  ) {
    return datasource.updateDevice(
      bearer,
      deviceNickname,
      deviceCareModes,
      deviceStatuses,
      deviceRecordId,
    );
  }
}
