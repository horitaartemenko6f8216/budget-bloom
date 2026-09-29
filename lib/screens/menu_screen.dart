import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/expense_repository.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/buttons.dart';
import '../widgets/stat_card.dart';

/// The week at a glance — an asymmetric editorial spread rather than a table.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.repository,
    required this.currency,
    required this.onLog,
    required this.onCategories,
    required this.onSettings,
  });

  final ExpenseRepository repository;
  final String currency;
  final VoidCallback onLog;
  final VoidCallback onCategories;
  final VoidCallback onSettings;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.contentRevealMs),
    );
    _reveal.forward();
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  Widget _staggered(Widget child, double begin, double end) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: _reveal,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseRepository repo = widget.repository;
    final bool empty = repo.isEmpty;
    final int weekTotal = repo.weekTotalMinor;
    final int today = repo.todayTotalMinor;
    final int average = repo.averagePerDayMinor;
    final bool showStats = !empty && today > 0 && average > 0;

    return AppBackground(
      asset: AppAssets.bgMenu,
      overlay: <Color>[
        const Color(0xFFF8F4FA).withValues(alpha: 0.90),
        const Color(0xFFF1E9F5).withValues(alpha: 0.86),
        const Color(0xFFEFE4F0).withValues(alpha: 0.92),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 6,
            right: 6,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                AppAssets.leafSprig,
                width: 120,
                fit: BoxFit.contain,
                errorBuilder:
                    (BuildContext c, Object e, StackTrace? s) =>
                        const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 44),
                  _staggered(
                    const Text(
                      'THIS WEEK · MON-SUN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                        color: AppPalette.textMuted,
                      ),
                    ),
                    0.0,
                    0.4,
                  ),
                  const SizedBox(height: 10),
                  _staggered(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatMinor(weekTotal, symbol: widget.currency),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          empty ? 'your week is still a seed' : 'spent so far',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    0.15,
                    0.6,
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: AppPalette.hairline),
                  const SizedBox(height: 20),
                  if (showStats)
                    _staggered(
                      StatCardRow(
                        cards: <StatCard>[
                          StatCard(
                            value: formatMinor(today, symbol: widget.currency),
                            label: 'today',
                            valueColor: AppPalette.primary,
                          ),
                          StatCard(
                            value:
                                formatMinor(average, symbol: widget.currency),
                            label: 'avg / day',
                            valueColor: AppPalette.tertiary,
                          ),
                        ],
                      ),
                      0.3,
                      0.8,
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Align(
                      alignment: const Alignment(0.55, 0.1),
                      child: Opacity(
                        opacity: empty ? 0.55 : 1.0,
                        child: Image.asset(
                          AppAssets.bloomBouquet,
                          height: 168,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (BuildContext c, Object e, StackTrace? s) =>
                                  const Icon(
                            Icons.local_florist_rounded,
                            size: 120,
                            color: AppPalette.primaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'three taps · no bank needed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  ),
                  _staggered(
                    PrimaryCta(
                      label: 'START LOGGING',
                      icon: Icons.edit_note_rounded,
                      height: 58,
                      useAssetBg: true,
                      onTap: widget.onLog,
                    ),
                    0.5,
                    1.0,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SecondaryCta(
                          label: 'CATEGORIES',
                          onTap: widget.onCategories,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryCta(
                          label: 'SETTINGS',
                          onTap: widget.onSettings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
