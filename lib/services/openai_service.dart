import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class OpenAIService {
  /// Calls the OpenAI Chat Completions API with automatic retry on rate-limit (429) errors.
  Future<String> _ask(String prompt) async {
    debugPrint('[OpenAI] Calling: ${Config.openaiUrl}');

    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final res = await http.post(
          Uri.parse(Config.openaiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Config.openaiApiKey}',
          },
          body: jsonEncode({
            'model': Config.openaiModel,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.7,
          }),
        );

        debugPrint('[OpenAI] Status code: ${res.statusCode} (attempt $attempt)');

        // Rate limited or quota exceeded
        if (res.statusCode == 429) {
          debugPrint('[OpenAI] 429 Response body: ${res.body}');
          if (attempt < maxRetries) {
            final waitSeconds = attempt * 15; // 15s, 30s, 45s
            debugPrint('[OpenAI] Rate limited. Waiting ${waitSeconds}s before retry...');
            await Future.delayed(Duration(seconds: waitSeconds));
            continue;
          } else {
            throw Exception(
              'OpenAI API error (429): ${res.body}',
            );
          }
        }

        if (res.statusCode != 200) {
          throw Exception('OpenAI API error (${res.statusCode}): ${res.body}');
        }

        final data = jsonDecode(res.body);

        if (data['choices'] == null || (data['choices'] as List).isEmpty) {
          throw Exception('No choices in OpenAI response');
        }

        return data['choices'][0]['message']['content'] ?? '';
      } catch (e) {
        debugPrint('[OpenAI] ERROR (attempt $attempt): $e');
        if (attempt == maxRetries) rethrow;
        // For non-429 errors, still retry with a short delay
        await Future.delayed(Duration(seconds: attempt * 5));
      }
    }

    throw Exception('OpenAI API failed after $maxRetries attempts');
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
