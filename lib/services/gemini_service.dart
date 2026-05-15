import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class GeminiService {
  /// Calls the Gemini API with automatic retry on rate-limit (429) errors.
  Future<String> _ask(String prompt) async {
    final url = '${Config.geminiUrl}?key=${Config.geminiApiKey}';
    debugPrint('[Gemini] Calling: ${Config.geminiUrl}');

    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        );

        debugPrint('[Gemini] Status code: ${res.statusCode} (attempt $attempt)');

        // Rate limited — wait and retry
        if (res.statusCode == 429) {
          if (attempt < maxRetries) {
            final waitSeconds = attempt * 15; // 15s, 30s, 45s
            debugPrint('[Gemini] Rate limited. Waiting ${waitSeconds}s before retry...');
            await Future.delayed(Duration(seconds: waitSeconds));
            continue;
          } else {
            throw Exception(
              'Gemini API rate limit exceeded after $maxRetries attempts. '
              'Please wait a minute and try again.',
            );
          }
        }

        if (res.statusCode != 200) {
          throw Exception('Gemini API error (${res.statusCode}): ${res.body}');
        }

        final data = jsonDecode(res.body);

        if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
          throw Exception('No candidates in Gemini response');
        }

        return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
      } catch (e) {
        debugPrint('[Gemini] ERROR (attempt $attempt): $e');
        if (attempt == maxRetries) rethrow;
        // For non-429 errors, still retry with a short delay
        await Future.delayed(Duration(seconds: attempt * 5));
      }
    }

    throw Exception('Gemini API failed after $maxRetries attempts');
  }

  // Extract job details from a pasted job description
  Future<Map<String, dynamic>> extractJobDetails(String jdText) async {
    final prompt = '''
Extract job details from the text below.
Return ONLY a raw JSON object with no markdown, no backticks, no explanation:
{
  "company": "",
  "role": "",
  "location": "",
  "salary": "",
  "tags": []
}

Job description:
$jdText
''';
    final raw = await _ask(prompt);
    final clean = raw.replaceAll(RegExp(r'```json|```'), '').trim();
    return jsonDecode(clean);
  }

  // Generate a follow-up email
  Future<String> generateFollowUp({
    required String company,
    required String role,
    String notes = '',
  }) async {
    final prompt = '''
Write a short professional follow-up email for a job application.
Company: $company
Role: $role
Notes: $notes

Under 150 words. Friendly and confident. No subject line.
''';
    return await _ask(prompt);
  }
}
