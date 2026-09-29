import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme.dart';

/// A flower bud you tap to tag the entry. The sprite sits straight on the card
/// — no clipping bubble around it.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    this.imageSize = 46,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: selected
              ? Color.alphaBlend(
                  category.color.withValues(alpha: 0.12), Colors.white)
              : Colors.white.withValues(alpha: 0.92),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: category.color
                      .withValues(alpha: selected ? 0.95 : 0.28),
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    category.asset,
                    height: imageSize,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stack) =>
                        Icon(category.icon,
                            size: imageSize * 0.8, color: category.color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: selected
                          ? category.color
                          : AppPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
