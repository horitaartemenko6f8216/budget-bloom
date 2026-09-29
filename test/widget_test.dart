import 'package:budget_bloom/game/expense_repository.dart';
import 'package:budget_bloom/game/models.dart';
import 'package:budget_bloom/theme.dart';
import 'package:budget_bloom/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeded repository stays mutable and totals correctly', () {
    final ExpenseRepository repo =
        ExpenseRepository(seed: buildSeedExpenses());

    expect(repo.entryCount, 12);
    expect(repo.weekTotalMinor, 428000);
    expect(repo.topCategoryId, 'food');

    repo.add(Expense(
      id: 'manual',
      amountMinor: 12000,
      categoryId: 'fun',
      createdAt: DateTime.now(),
    ));

    expect(repo.entryCount, 13);
    expect(repo.weekTotalMinor, 440000);
  });

  test('a repository built with no seed can still take entries', () {
    final ExpenseRepository repo = ExpenseRepository();
    expect(repo.isEmpty, isTrue);
    repo.add(Expense(
      id: 'first',
      amountMinor: 5000,
      categoryId: 'home',
      createdAt: DateTime.now(),
    ));
    expect(repo.weekTotalMinor, 5000);
  });

  test('expense survives a JSON round trip', () {
    final ExpenseRepository repo = ExpenseRepository(seed: <Expense>[
      Expense(
        id: 'a',
        amountMinor: 2500,
        categoryId: 'health',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      ),
    ]);
    final List<Expense> restored = ExpenseRepository.decode(repo.encode());
    expect(restored.length, 1);
    expect(restored.first.amountMinor, 2500);
    expect(restored.first.categoryId, 'health');
  });

  test('amounts are grouped in threes', () {
    expect(formatMinor(428000), '4 280 ₽');
    expect(formatMinor(0), '0 ₽');
  });

  testWidgets('a pair of stat cards renders value and label',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: StatCardRow(
          cards: <StatCard>[
            const StatCard(
              value: '640 ₽',
              label: 'today',
              valueColor: AppPalette.primary,
            ),
            const StatCard(
              value: '611 ₽',
              label: 'avg / day',
              valueColor: AppPalette.tertiary,
            ),
          ],
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('640 ₽'), findsOneWidget);
    expect(find.text('AVG / DAY'), findsOneWidget);
  });
}
