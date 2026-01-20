// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sadana/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const SadanaApp(),
      ),
    );

    // Verify that the first screen shows up (e.g., SplashScreen or LoginScreen).
    // This is a basic check to ensure the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
