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
      };

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'],
        company: json['company'],
        role: json['role'],
        location: json['location'] ?? '',
        salary: json['salary'] ?? '',
        status: json['status'] ?? 'wishlist',
        notes: json['notes'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        appliedDate: json['appliedDate'] ?? '',
        createdAt: json['createdAt'],
        url: json['url'] ?? '',
        interviewDate: json['interviewDate'] ?? '',
        deadline: json['deadline'] ?? '',
        activityLog: List<Map<String, String>>.from(
          (json['activityLog'] ?? []).map(
            (e) => Map<String, String>.from(e),
          ),
        ),
      );

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
}
