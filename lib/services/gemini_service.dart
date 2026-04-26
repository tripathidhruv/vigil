import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiProvider = Provider<GeminiService>((ref) => GeminiService());

class GeminiService {
  // TODO: static const String apiKey = 'YOUR_GEMINI_API_KEY';

  Future<String> classifyIncident(String description) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'HIGH'; // Mock classification
  }
}
