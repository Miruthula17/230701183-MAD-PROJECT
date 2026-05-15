class UserProfile {
  String name;
  String email;
  String phone;
  String headline; // e.g. "Flutter Developer | 3 yrs exp"
  List<String> skills;
  String experience; // years of experience
  String education;
  String preferredRole;
  String preferredLocation;
  String preferredSalary;
  String resumeSummary; // AI-generated or user-written
  String preferredCategory; // Remotive category

  UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.headline = '',
    this.skills = const [],
    this.experience = '',
    this.education = '',
    this.preferredRole = '',
    this.preferredLocation = '',
    this.preferredSalary = '',
    this.resumeSummary = '',
    this.preferredCategory = 'software-dev',
  });

  /// Profile completeness as a percentage (0-100)
  int get completeness {
    int filled = 0;
    int total = 9;
    if (name.isNotEmpty) filled++;
    if (email.isNotEmpty) filled++;
    if (headline.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    if (experience.isNotEmpty) filled++;
    if (education.isNotEmpty) filled++;
    if (preferredRole.isNotEmpty) filled++;
    if (preferredLocation.isNotEmpty) filled++;
    if (resumeSummary.isNotEmpty) filled++;
    return ((filled / total) * 100).round();
  }

  String get strengthLabel {
    final score = completeness;
    if (score >= 80) return 'Strong';
    if (score >= 50) return 'Moderate';
    return 'Weak';
  }

  /// Next field to fill for profile improvement
  String get nextTip {
    if (name.isEmpty) return 'Add your name to get started';
    if (headline.isEmpty) return 'Add a headline (e.g. Flutter Developer)';
    if (skills.isEmpty) return 'Add your top skills';
    if (experience.isEmpty) return 'Add your experience level';
    if (education.isEmpty) return 'Add your education';
    if (preferredRole.isEmpty) return 'Set your preferred job role';
    if (preferredLocation.isEmpty) return 'Set your preferred location';
    if (email.isEmpty) return 'Add your email';
    if (resumeSummary.isEmpty) return 'Generate an AI resume summary!';
    return 'Profile is complete! 🎉';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'headline': headline,
        'skills': skills,
        'experience': experience,
        'education': education,
        'preferredRole': preferredRole,
        'preferredLocation': preferredLocation,
        'preferredSalary': preferredSalary,
        'resumeSummary': resumeSummary,
        'preferredCategory': preferredCategory,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        headline: json['headline'] ?? '',
        skills: List<String>.from(json['skills'] ?? []),
        experience: json['experience'] ?? '',
        education: json['education'] ?? '',
        preferredRole: json['preferredRole'] ?? '',
        preferredLocation: json['preferredLocation'] ?? '',
        preferredSalary: json['preferredSalary'] ?? '',
        resumeSummary: json['resumeSummary'] ?? '',
        preferredCategory: json['preferredCategory'] ?? 'software-dev',
      );
}
