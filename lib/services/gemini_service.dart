import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // TODO: Replace with your actual API key or fetch securely.
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: _apiKey,
    );
  }

  /// Analyzes the user's logged calories and workouts to provide actionable health advice.
  Future<String> getDailyTip(int consumedCalories, int goalCalories, String recentWorkout) async {
    final prompt = '''
    Act as a professional nutritionist and fitness coach.
    The user has a daily goal of $goalCalories kcal and has consumed $consumedCalories kcal today.
    Their most recent workout was: $recentWorkout.
    Provide a short, actionable health tip or motivation (max 2 sentences) based on this data.
    ''';

    try {
      if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        return 'Set your Gemini API key to get personalized tips!';
      }
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep up the great work!';
    } catch (e) {
      return 'Stay hydrated and keep moving! (Error fetching AI tip)';
    }
  }
}
