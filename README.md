# Job Tracker

A Flutter-based job application tracking app that helps users manage their job search process with AI assistance.

## Features

- **Dashboard**: Overview of job applications with statistics and charts
- **Job Board**: Kanban-style board to track application stages (Applied, Interviewing, Offered, Rejected)
- **Add/Edit Jobs**: Easily add new job applications with detailed information
- **AI Assistance**: Integrated with Gemini and OpenAI services for:
  - Auto-filling job application forms
  - Generating follow-up emails
  - Resume optimization suggestions
- **Follow-up Reminders**: Track and manage follow-up communications
- **Data Persistence**: Local storage using SharedPreferences
- **Charts and Analytics**: Visualize application progress with fl_chart

## Screenshots

*(Add screenshots here if available)*

## Installation

### Prerequisites

- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)
- Android Studio or VS Code with Flutter extensions

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd job_tracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure API keys for AI services:
   - Add your Gemini API key to `lib/services/gemini_service.dart`
   - Add your OpenAI API key to `lib/services/openai_service.dart`

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── config.dart                 # App configuration
├── main.dart                   # App entry point
├── models/
│   └── job.dart                # Job application model
├── providers/
│   └── jobs_provider.dart      # State management for jobs
├── screens/
│   ├── add_job_screen.dart     # Add/edit job screen
│   ├── board_screen.dart       # Kanban board view
│   ├── dashboard_screen.dart   # Dashboard with stats
│   └── followup_screen.dart    # Follow-up management
├── services/
│   ├── gemini_service.dart     # Gemini AI integration
│   └── openai_service.dart     # OpenAI integration
└── widgets/
    ├── ai_fill_sheet.dart      # AI form filling widget
    ├── column_list.dart        # Board column widget
    └── job_card.dart           # Job card widget
```

## Dependencies

- **flutter**: UI framework
- **provider**: State management
- **shared_preferences**: Local data persistence
- **http**: API calls
- **uuid**: Unique ID generation
- **fl_chart**: Data visualization
- **url_launcher**: Launch URLs
- **intl**: Internationalization

## Usage

1. **Dashboard**: View overall statistics and recent applications
2. **Board View**: Drag and drop jobs between stages
3. **Add Job**: Use the + button to add new applications
4. **AI Features**: Tap the AI button on job cards for assistance
5. **Follow-ups**: Access follow-up screen for communication tracking

## API Configuration

To use AI features, configure your API keys:

### Gemini Service
Replace `YOUR_GEMINI_API_KEY` in `lib/services/gemini_service.dart`

### OpenAI Service
Replace `YOUR_OPENAI_API_KEY` in `lib/services/openai_service.dart`

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue on the GitHub repository.
