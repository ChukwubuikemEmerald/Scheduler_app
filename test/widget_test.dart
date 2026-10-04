// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:student_app_project/app/app.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    // 1. Wrap your app in a ProviderScope for the test environment
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // 2. Allow the UI to settle after rendering
    await tester.pumpAndSettle();

    // 3. Write a new assertion that makes sense for your CourseScreen
    // For example, verify that a specific title or empty state text exists:
    expect(find.text('Courses'), findsOneWidget);

    // (Optional) Remove the old counter assertions:
    // expect(find.text('0'), findsOneWidget);
    // expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
