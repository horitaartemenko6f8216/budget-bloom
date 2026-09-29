import 'package:flutter/material.dart';

import '../theme.dart';

/// 3x4 numeric pad. Key height is passed in so the caller can keep the whole
/// controls block inside the bottom third of any phone.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onKey,
    required this.onBackspace,
    this.keyHeight = 56,
    this.gap = 10,
  });

  final void Function(String digits) onKey;
  final VoidCallback onBackspace;
  final double keyHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    const List<List<String>> rows = <List<String>>[
      <String>['1', '2', '3'],
      <String>['4', '5', '6'],
      <String>['7', '8', '9'],
      <String>['00', '0', 'back'],
    ];

    final List<Widget> children = <Widget>[];
    for (int r = 0; r < rows.length; r++) {
      if (r > 0) children.add(SizedBox(height: gap));
      final List<Widget> cells = <Widget>[];
      for (int c = 0; c < rows[r].length; c++) {
        if (c > 0) cells.add(SizedBox(width: gap));
        cells.add(Expanded(child: _buildKey(rows[r][c])));
      }
      children.add(Row(children: cells));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildKey(String token) {
    final bool isBack = token == 'back';
    return SizedBox(
      height: keyHeight,
      child: Material(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isBack ? onBackspace : () => onKey(token),
          child: Center(
            child: isBack
                ? const Icon(Icons.backspace_rounded,
                    size: 22, color: AppPalette.primary)
                : Text(
                    token,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textPrimary,
                      fontFeatures: kTabularFigures,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
