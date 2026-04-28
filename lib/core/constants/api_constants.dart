import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Read Grok API Key from .env file
  static String get grokApiKey => dotenv.env['GROK_API_KEY'] ?? '';
  static const String grokApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
}
