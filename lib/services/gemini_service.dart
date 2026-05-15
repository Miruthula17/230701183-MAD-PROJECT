import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user_profile.dart';

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

  // ═══════════════════════════════════════════════════════════
  // EXISTING FEATURES (kept from original)
  // ═══════════════════════════════════════════════════════════

  /// Extract job details from a pasted job description
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

  /// Generate a follow-up email
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

  // ═══════════════════════════════════════════════════════════
  // NEW AI FEATURES for JobGenie
  // ═══════════════════════════════════════════════════════════

  /// Get AI match score between user profile and a job
  Future<Map<String, dynamic>> getJobMatchScore({
    required UserProfile profile,
    required String jobTitle,
    required String jobDescription,
    required String jobCompany,
  }) async {
    final prompt = '''
You are a career matching AI. Analyze how well this candidate matches the job.

CANDIDATE PROFILE:
- Name: ${profile.name}
- Headline: ${profile.headline}
- Skills: ${profile.skills.join(', ')}
- Experience: ${profile.experience} years
- Education: ${profile.education}
- Preferred Role: ${profile.preferredRole}
- Preferred Location: ${profile.preferredLocation}

JOB POSTING:
- Company: $jobCompany
- Title: $jobTitle
- Description: ${jobDescription.length > 1000 ? jobDescription.substring(0, 1000) : jobDescription}

Return ONLY a raw JSON object with no markdown, no backticks:
{
  "score": 75,
  "strengths": ["strength1", "strength2"],
  "gaps": ["gap1", "gap2"],
  "tip": "One sentence advice"
}

Score should be 0-100. Be realistic.
''';
    final raw = await _ask(prompt);
    final clean = raw.replaceAll(RegExp(r'```json|```'), '').trim();
    return jsonDecode(clean);
  }

  /// Generate professional resume summary from profile
  Future<String> generateResume({required UserProfile profile}) async {
    final prompt = '''
Generate a professional resume summary for this candidate.

Name: ${profile.name}
Headline: ${profile.headline}
Skills: ${profile.skills.join(', ')}
Experience: ${profile.experience} years
Education: ${profile.education}
Preferred Role: ${profile.preferredRole}

Write a compelling 3-4 paragraph professional summary (under 200 words) that:
1. Opens with a strong professional identity statement
2. Highlights key technical skills and experience
3. Mentions education and career goals
4. Ends with a value proposition

Use professional tone. No bullet points. Plain text only.
''';
    return await _ask(prompt);
  }

  /// Generate interview preparation questions
  Future<Map<String, dynamic>> generateInterviewPrep({
    required String company,
    required String role,
    String? description,
  }) async {
    final prompt = '''
Generate interview preparation for this job.
Company: $company
Role: $role
${description != null && description.isNotEmpty ? 'Description: ${description.length > 500 ? description.substring(0, 500) : description}' : ''}

Return ONLY a raw JSON object with no markdown, no backticks:
{
  "technical": [
    {"question": "...", "tip": "Brief answering tip"},
    {"question": "...", "tip": "Brief answering tip"},
    {"question": "...", "tip": "Brief answering tip"}
  ],
  "behavioral": [
    {"question": "...", "tip": "Brief answering tip"},
    {"question": "...", "tip": "Brief answering tip"},
    {"question": "...", "tip": "Brief answering tip"}
  ],
  "company_specific": [
    {"question": "...", "tip": "Brief answering tip"},
    {"question": "...", "tip": "Brief answering tip"}
  ],
  "tips": ["tip1", "tip2", "tip3"]
}
''';
    final raw = await _ask(prompt);
    final clean = raw.replaceAll(RegExp(r'```json|```'), '').trim();
    return jsonDecode(clean);
  }

  /// Get personalized career insights
  Future<Map<String, dynamic>> getCareerInsights({
    required UserProfile profile,
    required int totalApplications,
    required int interviews,
    required int offers,
    required int rejections,
  }) async {
    final prompt = '''
Provide career insights for this job seeker.

Profile: ${profile.name}, ${profile.headline}
Skills: ${profile.skills.join(', ')}
Experience: ${profile.experience} years
Stats: $totalApplications applications, $interviews interviews, $offers offers, $rejections rejections

Return ONLY a raw JSON object with no markdown, no backticks:
{
  "overall_assessment": "2-3 sentence assessment of their job search",
  "tip_of_the_day": "One actionable career tip",
  "skill_suggestion": "One trending skill they should learn",
  "market_outlook": "Brief job market outlook for their field",
  "motivation": "Short motivational message"
}
''';
    final raw = await _ask(prompt);
    final clean = raw.replaceAll(RegExp(r'```json|```'), '').trim();
    return jsonDecode(clean);
  }
}
