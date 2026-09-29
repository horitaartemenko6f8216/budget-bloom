import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import 'models.dart';

/// In-memory store for the current week's entries.
///
/// The backing list is always built with [List.of] — assigning a `const []`
/// literal directly would make the very first `add()` throw
/// "Cannot add to an unmodifiable list".
class ExpenseRepository {
  ExpenseRepository({List<Expense>? seed})
      : _items = List<Expense>.of(seed ?? const <Expense>[]);

  final List<Expense> _items;

  List<Expense> get items => List<Expense>.unmodifiable(_items);

  int get entryCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  void add(Expense expense) => _items.insert(0, expense);

  void clear() => _items.clear();

  int get weekTotalMinor =>
      _items.fold<int>(0, (int sum, Expense e) => sum + e.amountMinor);

  int get todayTotalMinor {
    final DateTime now = DateTime.now();
    return _items
        .where((Expense e) =>
            e.createdAt.year == now.year &&
            e.createdAt.month == now.month &&
            e.createdAt.day == now.day)
        .fold<int>(0, (int sum, Expense e) => sum + e.amountMinor);
  }

  int get averagePerDayMinor => _items.isEmpty ? 0 : weekTotalMinor ~/ 7;

  int totalFor(String categoryId) => _items
      .where((Expense e) => e.categoryId == categoryId)
      .fold<int>(0, (int sum, Expense e) => sum + e.amountMinor);

  int countFor(String categoryId) =>
      _items.where((Expense e) => e.categoryId == categoryId).length;

  /// category id -> share of the weekly total (0..1).
  Map<String, double> shares() {
    final int total = weekTotalMinor;
    final Map<String, double> out = <String, double>{};
    if (total <= 0) return out;
    for (final Category c in kCategories) {
      final int amount = totalFor(c.id);
      if (amount > 0) out[c.id] = amount / total;
    }
    return out;
  }

  /// Category ids ordered by spend, richest first.
  List<String> rankedCategoryIds() {
    final List<Category> ranked = List<Category>.of(kCategories)
      ..removeWhere((Category c) => totalFor(c.id) <= 0);
    ranked.sort((Category a, Category b) => totalFor(b.id) - totalFor(a.id));
    return ranked.map((Category c) => c.id).toList(growable: false);
  }

  String? get topCategoryId {
    final List<String> ranked = rankedCategoryIds();
    return ranked.isEmpty ? null : ranked.first;
  }

  double weekProgress(int weeklyBudgetMinor) {
    if (weeklyBudgetMinor <= 0) return 0;
    final double p = weekTotalMinor / weeklyBudgetMinor;
    return p > 1.0 ? 1.0 : p;
  }

  String encode() =>
      jsonEncode(_items.map((Expense e) => e.toJson()).toList());

  static List<Expense> decode(String raw) {
    try {
      final Object? parsed = jsonDecode(raw);
      if (parsed is! List) return <Expense>[];
      return parsed
          .whereType<Map<String, dynamic>>()
          .map(Expense.fromJson)
          .toList();
    } catch (error) {
      debugPrint('ExpenseRepository.decode failed: $error');
      return <Expense>[];
    }
  }
}

/// A believable first-run week so the overview and the bloom are never empty.
List<Expense> buildSeedExpenses() {
  final DateTime now = DateTime.now();
  final List<List<int>> plan = <List<int>>[
    <int>[64000, 0],
    <int>[82000, 2],
    <int>[41000, 4],
    <int>[26000, 1],
    <int>[18000, 3],
    <int>[32000, 5],
    <int>[54000, 1],
    <int>[30000, 4],
    <int>[25000, 2],
    <int>[19000, 5],
    <int>[23000, 3],
    <int>[14000, 6],
  ];
  const List<String> catOrder = <String>[
    'food',
    'food',
    'food',
    'transport',
    'transport',
    'transport',
    'home',
    'home',
    'fun',
    'fun',
    'health',
    'other',
  ];

  final List<Expense> out = <Expense>[];
  for (int i = 0; i < plan.length; i++) {
    final DateTime created = now.subtract(Duration(days: plan[i][1], hours: i));
    out.add(Expense(
      id: 'seed_$i',
      amountMinor: plan[i][0],
      categoryId: catOrder[i],
      createdAt: created,
    ));
  }
  return out;
}
