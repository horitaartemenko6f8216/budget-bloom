import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/expense_repository.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_header.dart';

/// Every bud in the bed, with what it cost this week.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    super.key,
    required this.repository,
    required this.currency,
    required this.hidden,
    required this.onToggle,
    required this.onBack,
  });

  final ExpenseRepository repository;
  final String currency;
  final Set<String> hidden;
  final void Function(String id, bool visible) onToggle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      asset: AppAssets.bgMenu,
      overlay: <Color>[
        const Color(0xFFF8F4FA).withValues(alpha: 0.92),
        const Color(0xFFEFE4F0).withValues(alpha: 0.90),
      ],
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            ScreenHeader(title: 'CATEGORIES', onBack: onBack),
            Expanded(
              child: repository.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: EmptyState(
                          icon: Icons.local_florist_rounded,
                          title: 'no entries in this category yet',
                          hint: 'your buds open as soon as you log something',
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      itemCount: kCategories.length,
                      separatorBuilder: (BuildContext c, int i) =>
                          const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Category cat = kCategories[index];
                        return _CategoryRow(
                          category: cat,
                          amountLabel: formatMinor(
                            repository.totalFor(cat.id),
                            symbol: currency,
                          ),
                          entries: repository.countFor(cat.id),
                          visible: !hidden.contains(cat.id),
                          onToggle: (bool value) => onToggle(cat.id, value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amountLabel,
    required this.entries,
    required this.visible,
    required this.onToggle,
  });

  final Category category;
  final String amountLabel;
  final int entries;
  final bool visible;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.color.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          Opacity(
            opacity: visible ? 1.0 : 0.4,
            child: Image.asset(
              category.asset,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  Icon(category.icon, size: 34, color: category.color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  category.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entries == 1 ? '1 entry' : '$entries entries',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: category.color,
              fontFeatures: kTabularFigures,
            ),
          ),
          const SizedBox(width: 4),
          Switch(value: visible, onChanged: onToggle),
        ],
      ),
    );
  }
}
