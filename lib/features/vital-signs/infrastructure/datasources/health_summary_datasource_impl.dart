import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/vital-signs/domain/datasources/health_summary_datasource.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/mappers/health_summary_mapper.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class HealthSummaryDatasourceImpl implements HealthSummaryDatasource {
  final Dio dio;
  final KeyValueStorageService storageService;

  HealthSummaryDatasourceImpl({
    required this.storageService,
    Dio? dio,
  }) : dio = dio ??
            Dio(BaseOptions(
              baseUrl: Environment.apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
              },
            ));

  @override
  Future<List<HealthSummary>> fetchHealthSummary(String deviceRecordId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        print('>>> Token not found');
        throw Exception('Token not found');
      }

      final response = await dio.get(
        '/devices/$deviceRecordId/health-measures-monthly-summary',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Process the response as needed
      print('>>> Health summary fetched successfully: ${response.data}');

      return (response.data as List)
          .map((item) => HealthSummaryMapper.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print(
          '>>> Error fetching health summary: ${e.response?.data ?? e.message}');
      throw Exception(
          'Error fetching health summary: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<HealthSummary>> fetchHealthPrediction(
      String deviceRecordId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        print('>>> Token not found');
        throw Exception('Token not found');
      }

      final response = await dio.post(
        Environment.predictionServiceUrl,
        data: {'petTrackerDeviceRecordId': deviceRecordId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain,
        ),
      );

      print('>>> Raw response (String): ${response.data}');

      final List<dynamic> jsonList = jsonDecode(response.data);

      return jsonList
          .map((item) => HealthSummaryMapper.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print(
          '>>> Error fetching health summary: ${e.response?.data ?? e.message}');
      throw Exception(
          'Error fetching health summary: ${e.response?.data ?? e.message}');
    }
  }
}
