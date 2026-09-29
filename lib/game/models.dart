import 'package:flutter/material.dart';

import '../assets.dart';

/// A spending category. Colour + flower sprite are fixed per category.
@immutable
class Category {
  const Category({
    required this.id,
    required this.label,
    required this.color,
    required this.asset,
    required this.icon,
  });

  final String id;
  final String label;
  final Color color;
  final String asset;
  final IconData icon;
}

const List<Category> kCategories = <Category>[
  Category(
    id: 'food',
    label: 'FOOD',
    color: Color(0xFFE08DAC),
    asset: AppAssets.flowerFood,
    icon: Icons.restaurant_rounded,
  ),
  Category(
    id: 'transport',
    label: 'TRANSPORT',
    color: Color(0xFF7A5C9E),
    asset: AppAssets.flowerTransport,
    icon: Icons.directions_bus_rounded,
  ),
  Category(
    id: 'home',
    label: 'HOME',
    color: Color(0xFF9BC1BC),
    asset: AppAssets.flowerHome,
    icon: Icons.home_rounded,
  ),
  Category(
    id: 'fun',
    label: 'FUN',
    color: Color(0xFFC98BC0),
    asset: AppAssets.flowerFun,
    icon: Icons.local_cafe_rounded,
  ),
  Category(
    id: 'health',
    label: 'HEALTH',
    color: Color(0xFF87A8C9),
    asset: AppAssets.flowerHealth,
    icon: Icons.favorite_rounded,
  ),
  Category(
    id: 'other',
    label: 'OTHER',
    color: Color(0xFFA99BB5),
    asset: AppAssets.flowerOther,
    icon: Icons.more_horiz_rounded,
  ),
];

Category categoryById(String id) {
  for (final Category c in kCategories) {
    if (c.id == id) return c;
  }
  return kCategories.last;
}

/// A single logged expense. Amounts are stored in minor units so no double
/// rounding error can creep into the weekly total.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.amountMinor,
    required this.categoryId,
    required this.createdAt,
  });

  final String id;
  final int amountMinor;
  final String categoryId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amountMinor': amountMinor,
        'categoryId': categoryId,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    final Object? rawAmount = json['amountMinor'];
    final Object? rawDate = json['createdAt'];
    return Expense(
      id: (json['id'] ?? '').toString(),
      amountMinor: rawAmount is num ? rawAmount.toInt() : 0,
      categoryId: (json['categoryId'] ?? 'other').toString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        rawDate is num ? rawDate.toInt() : 0,
      ),
    );
  }
}

/// Formats minor units as a grouped amount, e.g. 428000 -> "4 280 ₽".
String formatMinor(int amountMinor, {String symbol = '₽'}) {
  final int whole = (amountMinor / 100).round();
  final String digits = whole.abs().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      out.write(' ');
    }
    out.write(digits[i]);
  }
  return '$out $symbol';
}
