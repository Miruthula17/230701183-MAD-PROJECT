import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/remotive_service.dart';

class SearchProvider extends ChangeNotifier {
  final RemotiveService _remotiveService = RemotiveService();

  List<Job> _searchResults = [];
  List<Job> _recommendedJobs = [];
  bool _isLoading = false;
  bool _isLoadingRecommended = false;
  String _error = '';
  String _searchQuery = '';
  String _selectedCategory = '';

  List<Job> get searchResults => _searchResults;
  List<Job> get recommendedJobs => _recommendedJobs;
  bool get isLoading => _isLoading;
  bool get isLoadingRecommended => _isLoadingRecommended;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  /// Search jobs with query and/or category
  Future<void> searchJobs({String? query, String? category}) async {
    _isLoading = true;
    _error = '';
    _searchQuery = query ?? _searchQuery;
    _selectedCategory = category ?? _selectedCategory;
    notifyListeners();

    try {
      _searchResults = await _remotiveService.searchJobs(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
        limit: 25,
      );
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch jobs. Please try again.';
      debugPrint('[SearchProvider] Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load recommended jobs
  Future<void> loadRecommendedJobs({String? category}) async {
    _isLoadingRecommended = true;
    notifyListeners();

    try {
      _recommendedJobs = await _remotiveService.getRecommendedJobs(
        category: category,
      );
    } catch (e) {
      debugPrint('[SearchProvider] Error loading recommended: $e');
    }

    _isLoadingRecommended = false;
    notifyListeners();
  }

  /// Set category filter
  void setCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = ''; // Toggle off
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _error = '';
    notifyListeners();
  }

  /// Clear cache and refresh
  Future<void> refresh() async {
    _remotiveService.clearCache();
    await searchJobs();
  }
}
