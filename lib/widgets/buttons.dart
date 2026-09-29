import 'package:flutter/material.dart';

import '../assets.dart';
import '../theme.dart';

/// Gradient call-to-action with a 110ms press dip. Icon is always 24dp and the
/// label's line height matches it, so nothing drifts off the baseline.
class PrimaryCta extends StatefulWidget {
  const PrimaryCta({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 56,
    this.useAssetBg = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  final bool useAssetBg;

  @override
  State<PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<PrimaryCta> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppPalette.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (widget.useAssetBg)
                  Image.asset(
                    AppAssets.buttonCta,
                    fit: BoxFit.cover,
                    errorBuilder: _fallbackFill,
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        AppPalette.primary
                            .withValues(alpha: widget.useAssetBg ? 0.86 : 1.0),
                        AppPalette.primaryLight
                            .withValues(alpha: widget.useAssetBg ? 0.86 : 1.0),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(widget.icon, size: 24, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _fallbackFill(BuildContext context, Object error, StackTrace? stack) {
  return const DecoratedBox(
    decoration: BoxDecoration(color: AppPalette.primary),
  );
}

/// Quiet paper-white companion button, 48dp so it still clears the tap target.
class SecondaryCta extends StatelessWidget {
  const SecondaryCta({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppPalette.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 24, color: AppPalette.primary),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  height: 24 / 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppPalette.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
