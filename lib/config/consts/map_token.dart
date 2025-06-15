import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapToken {
  static Future<String> getMapToken() async {
    await dotenv.load(fileName: ".env");
    return dotenv.env['MAP_API_TOKEN'] ?? 'No token found';
  }
}
