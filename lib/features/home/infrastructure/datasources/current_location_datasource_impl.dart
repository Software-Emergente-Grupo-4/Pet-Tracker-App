import 'dart:convert'; // Import para jsonDecode
import 'package:pet_tracker/features/home/domain/datasources/current_location_datasource.dart';
import 'package:pet_tracker/features/home/domain/entities/current_location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CurrentLocationDatasourceImpl extends CurrentLocationDatasource {
  WebSocketChannel? _channel;
  String baseUrl = 'wss://pet-tracker.azurewebsites.net';

  @override
  Stream<CurrentLocation> connectToCurrentLocationStream(String roomId) {
    disconnect();

    final uri = Uri.parse('$baseUrl/location-stream?room=$roomId');
    // print('Connecting to WebSocket at: $uri');
    _channel = WebSocketChannel.connect(uri);

    return _channel!.stream.map((event) {
      try {
        // print('Raw data received: $event');
        // Convertir el String JSON a Map<String, dynamic>
        final jsonData = jsonDecode(event) as Map<String, dynamic>;
        final location = CurrentLocation.fromJson(jsonData);
        // print('Parsed CurrentLocation: $location');
        return location;
      } catch (e) {
        // print('Error parsing WebSocket data: $e');
        return CurrentLocation(latitude: 0, longitude: 0, riskLevel: '');
      }
    }).handleError((error) {
      // print('WebSocket error: $error');
      return CurrentLocation(latitude: 0, longitude: 0, riskLevel: '');
    });
  }

  void disconnect() {
    if (_channel != null) {
      // print('Disconnecting from WebSocket');
      _channel!.sink.close();
      _channel = null;
    }
  }
}
