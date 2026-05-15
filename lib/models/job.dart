class Job {
  final String id;
  String company;
  String role;
  String location;
  String salary;
  String status; // wishlist | applied | interview | offer | rejected
  String notes;
  List<String> tags;
  String appliedDate;
  final int createdAt;
  String url;
  String interviewDate; // ISO 8601 date string
  String deadline; // ISO 8601 date string
  List<Map<String, String>> activityLog; // [{action, date}]

  // New fields for JobGenie
  String description; // Full job description (HTML)
  String jobType; // full_time, part_time, contract, freelance, internship
  String experienceLevel; // junior, mid, senior, lead
  String companyLogoUrl;
  List<String> skills; // Required skills
  bool isSaved; // Bookmarked by user
  int matchScore; // AI match score 0-100
  bool isFromSearch; // true if discovered via search
  String candidateRequiredLocation;
  String postedDate; // When the job was posted
  String category; // Job category

  Job({
    required this.id,
    required this.company,
    required this.role,
    this.location = '',
    this.salary = '',
    this.status = 'wishlist',
    this.notes = '',
    this.tags = const [],
    this.appliedDate = '',
    required this.createdAt,
    this.url = '',
    this.interviewDate = '',
    this.deadline = '',
    this.activityLog = const [],
    this.description = '',
    this.jobType = '',
    this.experienceLevel = '',
    this.companyLogoUrl = '',
    this.skills = const [],
    this.isSaved = false,
    this.matchScore = 0,
    this.isFromSearch = false,
    this.candidateRequiredLocation = '',
    this.postedDate = '',
    this.category = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'role': role,
        'location': location,
        'salary': salary,
        'status': status,
        'notes': notes,
        'tags': tags,
        'appliedDate': appliedDate,
        'createdAt': createdAt,
        'url': url,
        'interviewDate': interviewDate,
        'deadline': deadline,
        'activityLog': activityLog,
        'description': description,
        'jobType': jobType,
        'experienceLevel': experienceLevel,
        'companyLogoUrl': companyLogoUrl,
        'skills': skills,
        'isSaved': isSaved,
        'matchScore': matchScore,
        'isFromSearch': isFromSearch,
        'candidateRequiredLocation': candidateRequiredLocation,
        'postedDate': postedDate,
        'category': category,
      };

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id']?.toString() ?? '',
        company: json['company'] ?? '',
        role: json['role'] ?? '',
        location: json['location'] ?? '',
        salary: json['salary'] ?? '',
        status: json['status'] ?? 'wishlist',
        notes: json['notes'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        appliedDate: json['appliedDate'] ?? '',
        createdAt: json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
        url: json['url'] ?? '',
        interviewDate: json['interviewDate'] ?? '',
        deadline: json['deadline'] ?? '',
        activityLog: List<Map<String, String>>.from(
          (json['activityLog'] ?? []).map(
            (e) => Map<String, String>.from(e),
          ),
        ),
        description: json['description'] ?? '',
        jobType: json['jobType'] ?? '',
        experienceLevel: json['experienceLevel'] ?? '',
        companyLogoUrl: json['companyLogoUrl'] ?? '',
        skills: List<String>.from(json['skills'] ?? []),
        isSaved: json['isSaved'] ?? false,
        matchScore: json['matchScore'] ?? 0,
        isFromSearch: json['isFromSearch'] ?? false,
        candidateRequiredLocation: json['candidateRequiredLocation'] ?? '',
        postedDate: json['postedDate'] ?? '',
        category: json['category'] ?? '',
      );

  /// Create a Job from Remotive API response
  factory Job.fromRemotive(Map<String, dynamic> json) {
    final tags = <String>[];
    if (json['category'] != null) tags.add(json['category']);
    if (json['job_type'] != null) {
      tags.add(_formatJobType(json['job_type']));
    }

    return Job(
      id: 'remotive_${json['id']}',
      company: json['company_name'] ?? '',
      role: json['title'] ?? '',
      location: json['candidate_required_location'] ?? 'Worldwide',
      salary: json['salary'] ?? '',
      status: 'wishlist',
      tags: tags,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      jobType: json['job_type'] ?? '',
      companyLogoUrl: json['company_logo'] ?? '',
      isFromSearch: true,
      candidateRequiredLocation:
          json['candidate_required_location'] ?? 'Worldwide',
      postedDate: json['publication_date'] ?? '',
      category: json['category'] ?? '',
    );
  }

  static String _formatJobType(String type) {
    switch (type) {
      case 'full_time':
        return 'Full-time';
      case 'part_time':
        return 'Part-time';
      case 'contract':
        return 'Contract';
      case 'freelance':
        return 'Freelance';
      case 'internship':
        return 'Internship';
      default:
        return type;
    }
  }

  String get formattedJobType => _formatJobType(jobType);

  /// Days until interview, null if no date set
  int? get daysUntilInterview {
    if (interviewDate.isEmpty) return null;
    try {
      final date = DateTime.parse(interviewDate);
      return date.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  /// Days until deadline, null if no date set
  int? get daysUntilDeadline {
    if (deadline.isEmpty) return null;
    try {
      final date = DateTime.parse(deadline);
      return date.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  /// Time since posted
  String get timeAgo {
    if (postedDate.isEmpty) return '';
    try {
      final date = DateTime.parse(postedDate);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}
