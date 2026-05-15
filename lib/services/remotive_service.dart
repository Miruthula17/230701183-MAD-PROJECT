import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/job.dart';

class RemotiveService {
  // Cache to respect rate limits (2 requests/min)
  static final Map<String, _CacheEntry> _cache = {};
  static const _cacheDuration = Duration(minutes: 5);

  /// Search jobs from Remotive API
  Future<List<Job>> searchJobs({
    String? query,
    String? category,
    int limit = 20,
  }) async {
    final cacheKey = '${query ?? ''}_${category ?? ''}_$limit';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      debugPrint('[Remotive] Returning cached results for: $cacheKey');
      return cached.jobs;
    }

    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['search'] = query;
    if (category != null && category.isNotEmpty) params['category'] = category;
    params['limit'] = limit.toString();

    final uri = Uri.parse(Config.remotiveBaseUrl).replace(queryParameters: params);
    debugPrint('[Remotive] Fetching: $uri');

    try {
      final res = await http.get(uri);
      debugPrint('[Remotive] Status: ${res.statusCode}');

      if (res.statusCode != 200) {
        throw Exception('Remotive API error (${res.statusCode}): ${res.body}');
      }

      final data = jsonDecode(res.body);
      final List jobsJson = data['jobs'] ?? [];

      final jobs = jobsJson.map((j) => Job.fromRemotive(j)).toList();

      // Cache the results
      _cache[cacheKey] = _CacheEntry(jobs: jobs);
      debugPrint('[Remotive] Got ${jobs.length} jobs');
      return jobs;
    } catch (e) {
      debugPrint('[Remotive] ERROR: $e');
      // Return cached if available, even if expired
      if (cached != null) return cached.jobs;
      rethrow;
    }
  }

  /// Get featured/recommended jobs (latest from popular categories)
  Future<List<Job>> getRecommendedJobs({String? category}) async {
    return searchJobs(
      category: category ?? 'software-dev',
      limit: 10,
    );
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }
}

class _CacheEntry {
  final List<Job> jobs;
  final DateTime createdAt;

  _CacheEntry({required this.jobs}) : createdAt = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(createdAt) > RemotiveService._cacheDuration;
}
