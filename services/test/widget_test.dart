import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngovolunteer/main.dart';

Future<void> pumpPastSplash(WidgetTester tester) async {
  await tester.pumpWidget(const NgoVolunteerApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('Splash shows brand and flows to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const NgoVolunteerApp());

    expect(find.text('NGOVolunteer'), findsOneWidget);
    expect(find.text('Volunteer for impact'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Discover meaningful causes'), findsOneWidget);
  });

  testWidgets('Demo login signs in as volunteer', (WidgetTester tester) async {
    await pumpPastSplash(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('How will you help?'), findsOneWidget);

    await tester.tap(find.text('Already have an account?  Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Try the demo volunteer account'));
    await tester.pumpAndSettle();

    expect(find.text('Aarav Shah'), findsOneWidget);
    expect(find.text('Volunteer hours'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });

  testWidgets('Demo login signs in as NGO and shows NGO dashboard', (WidgetTester tester) async {
    await pumpPastSplash(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Already have an account?  Sign in'));
    await tester.pumpAndSettle();

    final ngoFinder = find.text('Try the demo NGO account');
    await tester.scrollUntilVisible(ngoFinder, 100, scrollable: find.byType(Scrollable).last);
    await tester.tap(ngoFinder);
    await tester.pumpAndSettle();

    expect(find.text('Green Earth Foundation'), findsWidgets);
    expect(find.text('Causes'), findsWidgets);
    expect(find.text('Open causes'), findsOneWidget);
  });
}