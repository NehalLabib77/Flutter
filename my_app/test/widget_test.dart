// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Add task smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that initially there are no tasks.
    expect(find.text('Add a task...'), findsOneWidget);

    // Enter a task
    await tester.enterText(find.byKey(const Key('taskField')), 'Test task');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the task is added.
    expect(find.text('Test task'), findsOneWidget);
  });
}
