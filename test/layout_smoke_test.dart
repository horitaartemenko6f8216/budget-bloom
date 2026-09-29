import 'package:budget_bloom/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('walks loader -> menu -> game -> result without overflowing',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 72, bottom: 144);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BudgetBloomApp());
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('LOADING…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 7000));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('START LOGGING'), findsOneWidget);

    await tester.tap(find.text('START LOGGING'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SAVE & GO'), findsOneWidget);

    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('00'));
    await tester.pump();
    await tester.tap(find.text('SAVE & GO'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('ADD AGAIN'), findsOneWidget);
    expect(find.text('WEEK IN BLOOM'), findsOneWidget);

    await tester.tap(find.text('BACK TO OVERVIEW'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('CATEGORIES'), findsOneWidget);

    await tester.tap(find.text('CATEGORIES'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('TRANSPORT'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('SETTINGS'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Weekly budget'), findsOneWidget);
  });

  testWidgets('idle game screen resolves to a result frame on its own',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 72, bottom: 144);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BudgetBloomApp());
    await tester.pump(const Duration(milliseconds: 8200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('START LOGGING'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SAVE & GO'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 41000));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('ADD AGAIN'), findsOneWidget);
  });
}
