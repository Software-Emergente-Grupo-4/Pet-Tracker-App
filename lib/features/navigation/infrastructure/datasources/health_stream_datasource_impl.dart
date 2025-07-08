import 'dart:convert';
import 'package:pet_tracker/features/navigation/domain/entities/health_measure.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HealthStreamDatasourceImpl {
  final String baseUrl;
  WebSocketChannel? _channel;

  HealthStreamDatasourceImpl({required this.baseUrl});

  Stream<HealthMeasure> connectToHealthStream(String roomId) {
    disconnect();

    final uri = Uri.parse('$baseUrl/health-measures-stream?room=$roomId');
    _channel = WebSocketChannel.connect(uri);

    return _channel!.stream.map((event) {
      try {
        final jsonData = jsonDecode(event as String);
        if (jsonData is List && jsonData.isNotEmpty) {
          return HealthMeasure.fromJson(jsonData.first);
        } else if (jsonData is Map<String, dynamic>) {
          return HealthMeasure.fromJson(jsonData);
        } else {
          return HealthMeasure(bpm: null, spo2: null);
        }
      } catch (e) {
        return HealthMeasure(bpm: null, spo2: null);
      }
    });
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null; // Liberar el recurso
    }
  }
}