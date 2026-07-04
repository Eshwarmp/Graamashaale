import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class AiService {
  static final AiService instance = AiService._internal();
  AiService._internal();

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  Future<List<Map<String, dynamic>>?> generateQuestions({
    required String subject,
    required int classLevel,
    required int part,
    required String medium,
    int count = 10,
  }) async {
    try {
      final prompt = _buildPrompt(
        subject: subject,
        classLevel: classLevel,
        part: part,
        medium: medium,
        count: count,
      );

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $groqApiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an expert educational content creator for Karnataka KSEEB syllabus. '
                          'Always respond with valid JSON only. No extra text, no markdown, no explanation.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                }
              ],
              'temperature': 0.7,
              'max_tokens': 4000,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices'][0]['message']['content'] as String;

        // Clean up response — remove markdown if present
        String cleaned = content.trim();
        if (cleaned.startsWith('```json')) {
          cleaned = cleaned.substring(7);
        }
        if (cleaned.startsWith('```')) {
          cleaned = cleaned.substring(3);
        }
        if (cleaned.endsWith('```')) {
          cleaned =
              cleaned.substring(0, cleaned.length - 3);
        }
        cleaned = cleaned.trim();

        final List<dynamic> questions =
            jsonDecode(cleaned);
        return questions
            .map((q) => Map<String, dynamic>.from(q))
            .toList();
      } else {
        print('❌ Groq API failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ AI Error: $e');
      return null;
    }
  }

  String _buildPrompt({
    required String subject,
    required int classLevel,
    required int part,
    required String medium,
    required int count,
  }) {
    final isKannada = medium == 'kannada';

    return '''Generate $count multiple choice questions for Karnataka KSEEB Class $classLevel $subject Part $part textbook.

Return ONLY a JSON array with exactly $count objects. Each object must have these exact keys:
{
  "question_english": "Question in English",
  "question_kannada": "ಕನ್ನಡದಲ್ಲಿ ಪ್ರಶ್ನೆ",
  "option_a": "First option",
  "option_b": "Second option", 
  "option_c": "Third option",
  "option_d": "Fourth option",
  "correct_option": "A"
}

Rules:
- correct_option must be exactly "A", "B", "C", or "D"
- Questions must be based on Class $classLevel $subject Part $part KSEEB syllabus
- Make questions clear and educational
- Vary difficulty from easy to hard
- ${isKannada ? 'Focus on Kannada medium students' : 'Use simple English'}
- Return ONLY the JSON array, nothing else

JSON array:''';
  }
}