import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/grain_painter.dart';

/// Dark plum splash — deliberately the opposite of the milky overview screen,
/// so the two frames can never be confused by the capture gate.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _barFill;
  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.loaderRevealMs),
    );
    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );
    _markScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _barFill = Tween<double>(begin: 0.0, end: 0.62).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();

    // Wall-clock handoff: the emulator can collapse animator durations to zero,
    // so the screen change must never hang off a controller status listener.
    _handoff = Timer(
      const Duration(milliseconds: AppConfig.loaderDurationMs),
      widget.onDone,
    );
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      asset: AppAssets.bgLoader,
      base: AppPalette.loaderTop,
      overlay: <Color>[
        AppPalette.loaderTop.withValues(alpha: 0.92),
        AppPalette.loaderMid.withValues(alpha: 0.88),
        AppPalette.loaderBottom.withValues(alpha: 0.94),
      ],
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const CustomPaint(
            painter: GrainPainter(points: 130000, alpha: 0.11),
            size: Size.infinite,
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 44, left: 32, right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: Container(
                        width: 164,
                        height: 164,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                          border: Border.all(
                            color: const Color(0xFFE7D8F2)
                                .withValues(alpha: 0.20),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          AppAssets.iconApp,
                          width: 132,
                          height: 132,
                          fit: BoxFit.contain,
                          errorBuilder: (BuildContext c, Object e,
                                  StackTrace? s) =>
                              const Icon(Icons.local_florist_rounded,
                                  size: 96, color: AppPalette.loaderSubText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeTransition(
                    opacity: _titleFade,
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'BUDGET BLOOM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6.0,
                            color: AppPalette.loaderText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 64,
                          height: 1,
                          color: AppPalette.secondary,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'a quiet notebook for everyday spending',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.6,
                            color: AppPalette.loaderSubText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  SizedBox(
                    width: 180,
                    height: 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _barFill,
                        builder: (BuildContext context, Widget? child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _barFill.value,
                            child: child,
                          );
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppPalette.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LOADING…',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: AppPalette.loaderCaption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
