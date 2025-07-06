import 'package:dio/dio.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/vital-signs/domain/datasource/health_datasource.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/mappers/health_mapper.dart';

class HealthDatasourceImpl extends HealthDatasource {
  final Dio dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));
  final KeyValueStorageService storageService;

  HealthDatasourceImpl({
    required this.storageService,
    Dio? dio,
  });

  @override
  Future<List<Health>> getHealthData(String deviceRecordId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null || deviceRecordId.isEmpty) {
        throw Exception('Token or Device ID not found');
      }
      final response = await dio.get(
        '/devices/$deviceRecordId/health-measures-monthly-summary',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return HealthMapper.fromJsonList(response.data as List<dynamic>);
    } on DioException catch (e) {
      throw Exception(
          'Error fetching health data: ${e.response?.data ?? e.message}');
    }
  }
}
