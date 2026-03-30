
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijoy24_app/main.dart';

void main() {
  testWidgets('Bijoy24 app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: Bijoy24App()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
