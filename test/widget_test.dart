import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:job_tracker/main.dart';
import 'package:job_tracker/providers/jobs_provider.dart';

void main() {
  testWidgets('App renders board screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => JobsProvider(),
        child: const JobTrackerApp(),
      ),
    );

    expect(find.text('Job Tracker'), findsOneWidget);
    expect(find.text('Add Job'), findsOneWidget);
  });
}
