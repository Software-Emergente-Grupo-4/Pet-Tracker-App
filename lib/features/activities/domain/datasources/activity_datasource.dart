import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/activity.dart';

class ActivityDatasource {
  final String baseUrl = 'https://pet-tracker.azurewebsites.net/api/v1';

  Future<List<Activity>> getActivitiesByDevice(String deviceId) async {
    final response = await http.get(Uri.parse('$baseUrl/devices/$deviceId/activities'));

    if (response.statusCode != 200) throw Exception('Error al cargar actividades');

    final List data = json.decode(response.body);
    return data.map((json) => Activity.fromJson(json)).toList();
  }
}
