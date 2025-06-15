import 'package:pet_tracker/features/devices/domain/entities/device.dart';

abstract class DeviceDatasource {
  Future<Device> assignDeviceToUser(String deviceRecordId, String userId);
  Future<List<Device>> getAllDevices(String userId);
  Future<Device> updateDevice(String bearer, String deviceNickname,
      String deviceCareModes, String deviceStatuses, String deviceRecordId);
}
