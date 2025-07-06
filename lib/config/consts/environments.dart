import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }

  static String apiUrl = dotenv.env['API_URL'] ?? 'API URL not found';
  static String chatBotUrl = 'https://pet-tracker-chatbot.azurewebsites.net/api/pet_tracker_chabot';
  static String predictionServiceUrl = 'https://pet-tracker-prediction-service.azurewebsites.net/api/predict-health-measures'; 
}
