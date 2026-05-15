class Config {
  // App branding
  static const String appName = 'JobGenie';
  static const String appTagline = 'AI-Powered Career Platform';

  // Gemini AI
  static const String geminiApiKey = 'AIzaSyD82_emFDQwuuSWENTOaH8ohy9pd3XJtuU';
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  // Remotive API — Free, no API key needed
  static const String remotiveBaseUrl = 'https://remotive.com/api/remote-jobs';

  // Job categories available on Remotive
  static const List<Map<String, String>> jobCategories = [
    {'id': 'software-dev', 'label': 'Software Dev'},
    {'id': 'design', 'label': 'Design'},
    {'id': 'marketing', 'label': 'Marketing'},
    {'id': 'customer-support', 'label': 'Support'},
    {'id': 'sales', 'label': 'Sales'},
    {'id': 'product', 'label': 'Product'},
    {'id': 'data', 'label': 'Data'},
    {'id': 'devops', 'label': 'DevOps'},
    {'id': 'finance-legal', 'label': 'Finance'},
    {'id': 'hr', 'label': 'HR'},
    {'id': 'qa', 'label': 'QA'},
    {'id': 'writing', 'label': 'Writing'},
    {'id': 'all-others', 'label': 'Other'},
  ];
}
