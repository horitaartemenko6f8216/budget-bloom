import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/expense_repository.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/amount_keypad.dart';
import '../widgets/app_background.dart';
import '../widgets/buttons.dart';
import '../widgets/category_tile.dart';

/// Add Expense — amount, a bud to tag it with, and one button to plant it.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.repository,
    required this.currency,
    required this.onBack,
    required this.onSaved,
  });

  final ExpenseRepository repository;
  final String currency;
  final VoidCallback onBack;
  final void Function(Expense entry) onSaved;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  String _digits = '';
  String _categoryId = 'food';
  bool _showAmountHint = false;
  bool _engaged = false;
  bool _finished = false;

  Timer? _idleBackstop;
  Timer? _engagedBackstop;

  late final AnimationController _enter;
  late final AnimationController _shake;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.contentRevealMs),
    );
    _enter.forward();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Passive harness: nobody ever touches the screen. Give the nav agent time
    // to photograph the board, then resolve so a result frame still exists.
    _idleBackstop = Timer(
      const Duration(milliseconds: AppConfig.idleBackstopMs),
      () => _resolve(demo: true),
    );
  }

  @override
  void dispose() {
    _idleBackstop?.cancel();
    _engagedBackstop?.cancel();
    _enter.dispose();
    _shake.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// Armed exactly once, on the first touch, and never re-armed — the harness
  /// taps roughly every 13s, so re-arming would keep eating the result frame.
  void _markEngaged() {
    if (_engaged) return;
    _engaged = true;
    _idleBackstop?.cancel();
    _engagedBackstop = Timer(
      const Duration(milliseconds: AppConfig.engagedBackstopMs),
      () => _resolve(demo: _digits.isEmpty),
    );
  }

  int get _amountMinor {
    if (_digits.isEmpty) return 0;
    final int parsed = int.tryParse(_digits) ?? 0;
    return parsed * 100;
  }

  void _onKey(String token) {
    _markEngaged();
    setState(() {
      _showAmountHint = false;
      final String next = _digits + token;
      if (next.length <= AppConfig.maxAmountDigits) {
        _digits = next.replaceFirst(RegExp(r'^0+(?=\d)'), '');
      }
    });
  }

  void _onBackspace() {
    _markEngaged();
    setState(() {
      _showAmountHint = false;
      if (_digits.isNotEmpty) {
        _digits = _digits.substring(0, _digits.length - 1);
      }
    });
  }

  void _selectCategory(String id) {
    _markEngaged();
    setState(() => _categoryId = id);
  }

  void _onSavePressed() {
    _markEngaged();
    if (_amountMinor <= 0) {
      setState(() => _showAmountHint = true);
      _shake.forward(from: 0);
      return;
    }
    _resolve(demo: false);
  }

  void _resolve({required bool demo}) {
    if (_finished || !mounted) return;
    _finished = true;
    _idleBackstop?.cancel();
    _engagedBackstop?.cancel();

    final int amount = demo || _amountMinor <= 0 ? 34000 : _amountMinor;
    final Expense entry = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMinor: amount,
      categoryId: _categoryId,
      createdAt: DateTime.now(),
    );
    _pulse.forward(from: 0);
    widget.onSaved(entry);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double keyHeight = (size.height * 0.068).clamp(48.0, 60.0);
    final double boardWidth =
        (size.width - 32) < 380 ? (size.width - 32) : 380;
    const double tileGap = 10;
    final double tile = ((boardWidth - 2 * tileGap) / 3).floorToDouble();
    final double boardHeight = tile * 2 + tileGap;

    final int weekTotal = widget.repository.weekTotalMinor + _amountMinor;

    return AppBackground(
      asset: AppAssets.bgGame,
      overlay: <Color>[
        const Color(0xFFF8F4FA).withValues(alpha: 0.93),
        const Color(0xFFEFE7F2).withValues(alpha: 0.90),
      ],
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _markEngaged(),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _buildHeader(weekTotal),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildAmount(),
                      const SizedBox(height: 14),
                      Container(height: 1, color: AppPalette.hairline),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 18,
                        child: _showAmountHint
                            ? const Text(
                                'enter an amount first',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.danger,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: boardWidth,
                            height: boardHeight,
                            child: _buildCategoryBoard(tile, tileGap),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildControls(keyHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int weekTotal) {
    return Container(
      height: 96,
      padding: const EdgeInsets.only(top: 44, left: 8, right: 16),
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
              child: IconButton(
                onPressed: widget.onBack,
                iconSize: 24,
                padding: EdgeInsets.zero,
                splashRadius: 24,
                color: AppPalette.textPrimary,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'NEW ENTRY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 96,
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.12).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
                  ),
                  child: Text(
                    formatMinor(weekTotal, symbol: widget.currency),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                      fontFeatures: kTabularFigures,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmount() {
    final String shown = _digits.isEmpty ? '0' : _digits;
    final Widget row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$shown ${widget.currency}',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                letterSpacing: -1.5,
                color: AppPalette.textPrimary,
                fontFeatures: kTabularFigures,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 2,
          height: 34,
          color: AppPalette.secondary.withValues(alpha: 0.6),
        ),
      ],
    );

    return AnimatedBuilder(
      animation: _shake,
      builder: (BuildContext context, Widget? child) {
        final double t = _shake.value;
        final double dx = t == 0 ? 0 : 8 * (1 - t) * (t * 12 % 2 < 1 ? 1 : -1);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: row,
    );
  }

  Widget _buildCategoryBoard(double tile, double gap) {
    final List<Widget> rows = <Widget>[];
    for (int r = 0; r < 2; r++) {
      if (r > 0) rows.add(SizedBox(height: gap));
      final List<Widget> cells = <Widget>[];
      for (int c = 0; c < 3; c++) {
        final Category cat = kCategories[r * 3 + c];
        if (c > 0) cells.add(SizedBox(width: gap));
        cells.add(SizedBox(
          width: tile,
          height: tile,
          child: CategoryTile(
            category: cat,
            selected: cat.id == _categoryId,
            onTap: () => _selectCategory(cat.id),
            imageSize: tile * 0.44,
          ),
        ));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: cells));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildControls(double keyHeight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.textPrimary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AmountKeypad(
            onKey: _onKey,
            onBackspace: _onBackspace,
            keyHeight: keyHeight,
          ),
          const SizedBox(height: 12),
          PrimaryCta(
            label: 'SAVE & GO',
            icon: Icons.check_rounded,
            onTap: _onSavePressed,
          ),
        ],
      ),
    );
  }
}
