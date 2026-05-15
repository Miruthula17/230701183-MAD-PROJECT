import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:job_tracker/main.dart';
import 'package:job_tracker/providers/jobs_provider.dart';

void main() {
  testWidgets('App renders board screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => JobsProvider(),
        child: const JobGenieApp(),
      ),
    );

    expect(find.text('My Applications'), findsOneWidget);
    expect(find.text('Add Job'), findsOneWidget);
  });
}
