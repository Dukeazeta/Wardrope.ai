// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:warddropeai/main.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
<<<<<<< HEAD
    await tester.pumpWidget(const WardrobeApp());

    // Verify that onboarding screen is displayed
    expect(find.text('Welcome to Wardrobe.ai'), findsOneWidget);
=======
    await tester.pumpWidget(const WardropeApp());

    // Verify that onboarding screen is displayed
    expect(find.text('Welcome to Wardrope.ai'), findsOneWidget);
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    expect(find.text('Your AI-powered fashion companion'), findsOneWidget);
  });
}
