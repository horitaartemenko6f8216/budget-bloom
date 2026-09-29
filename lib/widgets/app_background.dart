import 'package:flutter/material.dart';

/// Every screen sits on an AI-rendered background plus a tinted gradient wash,
/// so no screen is ever a flat single-colour Material surface.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.asset,
    required this.overlay,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.radial = false,
    this.radialCenter = Alignment.center,
    this.radialRadius = 1.1,
    this.base = const Color(0xFFF8F4FA),
  });

  final String asset;
  final List<Color> overlay;
  final Widget child;
  final Alignment begin;
  final Alignment end;
  final bool radial;
  final Alignment radialCenter;
  final double radialRadius;
  final Color base;

  @override
  Widget build(BuildContext context) {
    final Gradient gradient = radial
        ? RadialGradient(
            center: radialCenter,
            radius: radialRadius,
            colors: overlay,
          )
        : LinearGradient(begin: begin, end: end, colors: overlay);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: base,
        image: DecorationImage(
          image: AssetImage(asset),
          fit: BoxFit.cover,
          onError: _ignoreMissingAsset,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

void _ignoreMissingAsset(Object error, StackTrace? stack) {
  debugPrint('AppBackground: background image unavailable ($error)');
}
