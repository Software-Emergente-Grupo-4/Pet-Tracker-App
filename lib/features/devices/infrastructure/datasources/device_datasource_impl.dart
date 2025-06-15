import 'package:dio/dio.dart';
import 'package:pet_tracker/config/config.dart';
import 'package:pet_tracker/features/devices/domain/domain.dart';
import 'package:pet_tracker/features/devices/infrastructure/mappers/device_mapper.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class DeviceDatasourceImpl extends DeviceDatasource {
  final Dio dio;
  final KeyValueStorageService storageService;

  DeviceDatasourceImpl({
    required this.storageService,
    Dio? dio,
  }) : dio = dio ??
            Dio(BaseOptions(
              baseUrl: Environment.apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  @override
  Future<Device> assignDeviceToUser(
      String deviceRecordId, String userId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) throw Exception('Token not found');

      final response = await dio.post(
        '/devices/assign',
        data: {
          'petTrackerDeviceRecordId': deviceRecordId,  // <-- actualizado
          'userId': int.parse(userId), // <-- aseguramos que sea int
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return DeviceMapper.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Error assigning device';
      throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          error: errorMessage);
    }
  }

  @override
  Future<List<Device>> getAllDevices(String userId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) throw Exception('Token not found');

      final response = await dio.get(
        '/users/$userId/devices',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((deviceData) => DeviceMapper.fromJson(deviceData))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'Error fetching devices: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<Device> updateDevice(
    String bearer,
    String deviceNickname,
    String deviceCareModes,
    String deviceStatuses,
    String deviceRecordId,
  ) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) throw Exception('Token not found');

      final response = await dio.put(
        '/devices/$deviceRecordId',
        data: {
          'bearer': bearer,
          'deviceNickname': deviceNickname,
          'deviceCareModes': deviceCareModes,
          'deviceStatuses': deviceStatuses,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return DeviceMapper.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Error updating device: ${e.response?.data ?? e.message}');
    }
  }
}
