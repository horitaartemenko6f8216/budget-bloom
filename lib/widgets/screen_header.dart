import 'package:flutter/material.dart';

import '../theme.dart';

/// Editorial header: 44dp of status-bar breathing room on top of a 52dp row,
/// so a 48dp tap target never has to fight the notch.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.only(top: 44, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        border: const Border(
          bottom: BorderSide(color: AppPalette.hairline, width: 1),
        ),
      ),
      child: SizedBox(
        height: 52,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: onBack == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: onBack,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      splashRadius: 24,
                      color: AppPalette.textPrimary,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 72,
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
