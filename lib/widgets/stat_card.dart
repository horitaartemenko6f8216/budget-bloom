import 'package:flutter/material.dart';

import '../theme.dart';

/// One statistic. Deliberately raster-free: an 8dp accent dot carries the
/// semantics so two cards side by side always read as the same size.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: valueColor.withValues(alpha: 0.33),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: valueColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: valueColor,
                fontFeatures: kTabularFigures,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of exactly two cards, or nothing at all — a lone pill looks orphaned.
class StatCardRow extends StatelessWidget {
  const StatCardRow({super.key, required this.cards});

  final List<StatCard> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.length < 2) return const SizedBox.shrink();
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 12));
      children.add(Expanded(child: cards[i]));
    }
    // IntrinsicHeight bounds the row so `stretch` can equalise the two cards
    // even when the parent column hands down an unbounded height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
