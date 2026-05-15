import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';

class JobsProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _savedJobs = []; // Bookmarked from search
  final _uuid = const Uuid();
  static const _storageKey = 'jobs_v2';
  static const _savedKey = 'saved_jobs_v1';

  // Search & filter state
  String _searchQuery = '';
  String? _statusFilter;
  String _sortBy = 'newest'; // newest, company, salary

  List<Job> get jobs => _jobs;
  List<Job> get savedJobs => _savedJobs;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String get sortBy => _sortBy;

  List<Job> byStatus(String status) {
    var filtered = _jobs.where((j) => j.status == status);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((j) =>
          j.company.toLowerCase().contains(q) ||
          j.role.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q) ||
          j.tags.any((t) => t.toLowerCase().contains(q)));
    }
    final list = filtered.toList();
    _applySorting(list);
    return list;
  }

  List<Job> get filteredJobs {
    var list = _jobs.toList();
    if (_statusFilter != null) {
      list = list.where((j) => j.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((j) =>
          j.company.toLowerCase().contains(q) ||
          j.role.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q) ||
          j.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    _applySorting(list);
    return list;
  }

  void _applySorting(List<Job> list) {
    switch (_sortBy) {
      case 'company':
        list.sort((a, b) => a.company.toLowerCase().compareTo(b.company.toLowerCase()));
        break;
      case 'salary':
        list.sort((a, b) => b.salary.compareTo(a.salary));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  // Stats
  int get totalJobs => _jobs.length;
  int countByStatus(String status) => _jobs.where((j) => j.status == status).length;

  double get responseRate {
    if (_jobs.isEmpty) return 0;
    final responded = _jobs.where(
      (j) => j.status == 'interview' || j.status == 'offer',
    ).length;
    return (responded / _jobs.length) * 100;
  }

  List<Job> get recentJobs {
    final sorted = _jobs.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<Job> get upcomingInterviews {
    return _jobs
        .where((j) {
          final days = j.daysUntilInterview;
          return days != null && days >= 0;
        })
        .toList()
      ..sort((a, b) =>
          (a.daysUntilInterview ?? 999).compareTo(b.daysUntilInterview ?? 999));
  }

  // Weekly activity data for chart (last 7 days)
  Map<String, int> get weeklyActivity {
    final now = DateTime.now();
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = DateFormat('EEE').format(day);
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      result[key] = _jobs.where((j) {
        final created = DateTime.fromMillisecondsSinceEpoch(j.createdAt);
        return created.isAfter(dayStart) && created.isBefore(dayEnd);
      }).length;
    }
    return result;
  }

  JobsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // Try v2 first, then fall back to v1
    var raw = prefs.getString(_storageKey);
    raw ??= prefs.getString('jobs_v1');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _jobs = decoded.map((e) => Job.fromJson(e)).toList();
    }

    // Load saved jobs
    final savedRaw = prefs.getString(_savedKey);
    if (savedRaw != null) {
      final List decoded = jsonDecode(savedRaw);
      _savedJobs = decoded.map((e) => Job.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_jobs.map((j) => j.toJson()).toList()),
    );
  }

  Future<void> _saveSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _savedKey,
      jsonEncode(_savedJobs.map((j) => j.toJson()).toList()),
    );
  }

  void addJob(Job job) {
    _addActivity(job, 'Created');
    _jobs.add(job);
    _save();
    notifyListeners();
  }

  void updateJob(String id, Job updated) {
    final i = _jobs.indexWhere((j) => j.id == id);
    if (i != -1) {
      _addActivity(updated, 'Updated details');
      _jobs[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteJob(String id) {
    _jobs.removeWhere((j) => j.id == id);
    _save();
    notifyListeners();
  }

  void moveJob(String id, String newStatus) {
    final i = _jobs.indexWhere((j) => j.id == id);
    if (i != -1) {
      final oldStatus = _jobs[i].status;
      _jobs[i].status = newStatus;
      _addActivity(_jobs[i], 'Moved from $oldStatus to $newStatus');
      _save();
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════
  // NEW: Saved/Bookmarked Jobs
  // ═══════════════════════════════════════════════

  bool isJobSaved(String jobId) {
    return _savedJobs.any((j) => j.id == jobId);
  }

  void toggleSaveJob(Job job) {
    final idx = _savedJobs.indexWhere((j) => j.id == job.id);
    if (idx != -1) {
      _savedJobs.removeAt(idx);
    } else {
      final saved = Job.fromJson(job.toJson());
      saved.isSaved = true;
      _savedJobs.add(saved);
    }
    _saveSaved();
    notifyListeners();
  }

  /// Add a job from search results to applications
  void addFromSearch(Job searchJob) {
    final job = Job.fromJson(searchJob.toJson());
    job.status = 'applied';
    job.appliedDate = DateTime.now().toIso8601String();
    _addActivity(job, 'Applied from search');
    _jobs.add(job);
    _save();
    notifyListeners();
  }

  void _addActivity(Job job, String action) {
    final log = List<Map<String, String>>.from(job.activityLog);
    log.add({
      'action': action,
      'date': DateTime.now().toIso8601String(),
    });
    job.activityLog = log;
  }

  Job newJob() => Job(
        id: _uuid.v4(),
        company: '',
        role: '',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  /// Export all jobs to CSV string
  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Company,Role,Location,Salary,Status,Tags,URL,Interview Date,Deadline,Applied Date,Notes');
    for (final job in _jobs) {
      buffer.writeln(
        '"${_csvEscape(job.company)}","${_csvEscape(job.role)}","${_csvEscape(job.location)}",'
        '"${_csvEscape(job.salary)}","${_csvEscape(job.status)}","${_csvEscape(job.tags.join('; '))}",'
        '"${_csvEscape(job.url)}","${_csvEscape(job.interviewDate)}","${_csvEscape(job.deadline)}",'
        '"${_csvEscape(job.appliedDate)}","${_csvEscape(job.notes)}"',
      );
    }
    return buffer.toString();
  }

  String _csvEscape(String val) => val.replaceAll('"', '""');
}
