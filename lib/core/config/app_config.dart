import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static int get timeoutSeconds => 30;
}
