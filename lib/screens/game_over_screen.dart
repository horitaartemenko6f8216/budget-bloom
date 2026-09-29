import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/expense_repository.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/bloom_garden.dart';
import '../widgets/buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

/// Weekly Bloom — the result frame. The week is redrawn as a flower bed the
/// moment an entry lands.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.repository,
    required this.currency,
    required this.lastEntry,
    required this.onAddAgain,
    required this.onMenu,
  });

  final ExpenseRepository repository;
  final String currency;
  final Expense? lastEntry;
  final VoidCallback onAddAgain;
  final VoidCallback onMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bloom;

  @override
  void initState() {
    super.initState();
    _bloom = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.bloomRevealMs),
    );
    _bloom.forward();
  }

  @override
  void dispose() {
    _bloom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseRepository repo = widget.repository;
    final bool empty = repo.isEmpty;
    final List<String> ranked = repo.rankedCategoryIds();
    final Map<String, double> shares = repo.shares();
    final Expense? last = widget.lastEntry;
    final String? topId = repo.topCategoryId;

    final String subtitle = last == null
        ? 'nothing planted yet'
        : 'saved · ${categoryById(last.categoryId).label} · '
            '${formatMinor(last.amountMinor, symbol: widget.currency)}';

    final List<Widget> stems = <Widget>[];
    for (final String id in ranked.take(4)) {
      final Category cat = categoryById(id);
      if (stems.isNotEmpty) stems.add(const SizedBox(height: 10));
      stems.add(StemBar(
        label: cat.label,
        amountLabel:
            formatMinor(repo.totalFor(id), symbol: widget.currency),
        share: shares[id] ?? 0,
        color: cat.color,
      ));
    }

    final String topLabel = topId == null ? '' : categoryById(topId).label;
    final bool showStats = !empty && repo.entryCount > 0 && topLabel.isNotEmpty;

    return AppBackground(
      asset: AppAssets.bgMenu,
      radial: true,
      radialCenter: const Alignment(0, -0.35),
      radialRadius: 1.1,
      overlay: <Color>[
        Colors.white.withValues(alpha: 0.88),
        const Color(0xFFEDE1F0).withValues(alpha: 0.94),
      ],
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 8,
            right: 8,
            child: Opacity(
              opacity: 0.30,
              child: Image.asset(
                AppAssets.leafSprig,
                width: 110,
                fit: BoxFit.contain,
                errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
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
                  const Text(
                    'WEEK IN BLOOM',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4.0,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: empty
                            ? const EmptyState(
                                icon: Icons.local_florist_rounded,
                                title: 'nothing planted yet',
                                hint: 'log one expense and the bed fills in',
                              )
                            : BloomGarden(
                                rankedIds: ranked,
                                shares: shares,
                                animation: _bloom,
                              ),
                      ),
                    ),
                  ),
                  if (stems.isNotEmpty) ...<Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: stems,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (showStats) ...<Widget>[
                    StatCardRow(
                      cards: <StatCard>[
                        StatCard(
                          value: repo.entryCount.toString(),
                          label: 'entries',
                          valueColor: AppPalette.primary,
                        ),
                        StatCard(
                          value: topLabel,
                          label: 'top bloom',
                          valueColor: AppPalette.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  PrimaryCta(
                    label: 'ADD AGAIN',
                    icon: Icons.add_rounded,
                    onTap: widget.onAddAgain,
                  ),
                  const SizedBox(height: 10),
                  SecondaryCta(
                    label: 'BACK TO OVERVIEW',
                    onTap: widget.onMenu,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
