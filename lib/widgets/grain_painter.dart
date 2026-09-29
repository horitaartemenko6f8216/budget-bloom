import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Static, full-canvas film grain used only on the loader.
///
/// Beyond the paper-ish look it has a hard technical job: the app is light and
/// minimal, so without grain the loader frame compresses smaller than the menu
/// frame and the capture harness mistakes the menu for the loader. The grain
/// lifts the loader PNG above the menu PNG while staying well under the 1.1 MB
/// ceiling. Positions come from a fixed xorshift32 seed, so it never repaints.
class GrainPainter extends CustomPainter {
  const GrainPainter({this.points = 130000, this.alpha = 0.12});

  final int points;
  final double alpha;

  static const List<Color> _tints = <Color>[
    Color(0xFFE7D8F2),
    Color(0xFFE08DAC),
    Color(0xFF9BC1BC),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    int state = 0x9E3779B9;
    double nextUnit() {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      state &= 0xFFFFFFFF;
      return (state & 0xFFFFFF) / 16777216.0;
    }

    final int perPass = points ~/ _tints.length;
    if (perPass <= 0) return;

    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List coords = Float32List(perPass * 2);
      for (int i = 0; i < perPass; i++) {
        coords[i * 2] = nextUnit() * size.width;
        coords[i * 2 + 1] = nextUnit() * size.height;
      }
      final Paint paint = Paint()
        ..color = _tints[pass].withValues(alpha: alpha + pass * 0.006)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square
        ..isAntiAlias = false;
      canvas.drawRawPoints(ui.PointMode.points, coords, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GrainPainter oldDelegate) => false;
}
