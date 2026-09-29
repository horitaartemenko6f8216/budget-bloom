import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/models.dart';
import '../theme.dart';

/// The week as a flower bed: a bouquet in the middle, the three heaviest
/// categories opening around it. All Positioned offsets stay positive so
/// nothing leaks past a rounded edge.
class BloomGarden extends StatelessWidget {
  const BloomGarden({
    super.key,
    required this.rankedIds,
    required this.shares,
    required this.animation,
    this.width = 300,
    this.height = 190,
  });

  final List<String> rankedIds;
  final Map<String, double> shares;
  final Animation<double> animation;
  final double width;
  final double height;

  static const List<Offset> _slots = <Offset>[
    Offset(8, 62),
    Offset(236, 46),
    Offset(122, 126),
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> top = rankedIds.take(_slots.length).toList();

    final List<Widget> layers = <Widget>[
      Positioned(
        left: 70,
        top: 8,
        child: Image.asset(
          AppAssets.bloomBouquet,
          width: 160,
          height: 160,
          fit: BoxFit.contain,
          errorBuilder: (BuildContext c, Object e, StackTrace? s) => const Icon(
            Icons.local_florist_rounded,
            size: 120,
            color: AppPalette.primaryLight,
          ),
        ),
      ),
    ];

    for (int i = 0; i < top.length; i++) {
      final Category cat = categoryById(top[i]);
      final double share = shares[cat.id] ?? 0;
      final double scale = 0.7 + 0.5 * share;
      final double begin = 0.15 * i;
      layers.add(Positioned(
        left: _slots[i].dx,
        top: _slots[i].dy,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: scale).animate(
            CurvedAnimation(
              parent: animation,
              curve: Interval(begin, begin + 0.6, curve: Curves.easeOutBack),
            ),
          ),
          child: Opacity(
            opacity: 0.55 + 0.45 * share,
            child: Image.asset(
              cat.asset,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  Icon(cat.icon, size: 44, color: cat.color),
            ),
          ),
        ),
      ));
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(clipBehavior: Clip.hardEdge, children: layers),
    );
  }
}

/// One category as a stem: label, amount, and a bar that fills with its share.
class StemBar extends StatelessWidget {
  const StemBar({
    super.key,
    required this.label,
    required this.amountLabel,
    required this.share,
    required this.color,
  });

  final String label;
  final String amountLabel;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double clamped = share.clamp(0.04, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppPalette.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              amountLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: kTabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
