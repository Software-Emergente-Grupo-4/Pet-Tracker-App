import 'package:dio/dio.dart';
import 'package:pet_tracker/config/config.dart';
import 'package:pet_tracker/features/activities/domain/entities/activity.dart';
import 'package:pet_tracker/features/activities/infrastructure/mappers/activity_mapper.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import '../../domain/datasources/activity_datasource.dart';

class ActivityDatasourceImpl extends ActivityDatasource {
  final Dio dio;
  final KeyValueStorageService storageService;

  ActivityDatasourceImpl({
    Dio? dio,
    required this.storageService,
  }) : dio = dio ?? Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<List<Activity>> getActivities(String deviceRecordId) async {
    final token = await storageService.getValue<String>('token');
    if (token == null) throw Exception('Token not found');

    final response = await dio.get(
      '/devices/$deviceRecordId/activities',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data as List)
        .map((json) => ActivityMapper.fromJson(json))
        .toList();
  }
}
