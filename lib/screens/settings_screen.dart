import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/screen_header.dart';

/// The few knobs this notebook has. No accounts, no sync, no analytics.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.weeklyBudgetMinor,
    required this.currency,
    required this.weekStartsMonday,
    required this.onBudgetChanged,
    required this.onCurrencyChanged,
    required this.onWeekStartChanged,
    required this.onReset,
    required this.onBack,
  });

  final int weeklyBudgetMinor;
  final String currency;
  final bool weekStartsMonday;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<bool> onWeekStartChanged;
  final VoidCallback onReset;
  final VoidCallback onBack;

  Future<void> _editBudget(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: (weeklyBudgetMinor ~/ 100).toString(),
    );
    final int? picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 22,
            bottom: 22 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'WEEKLY BUDGET',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                  color: AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF3EDF7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixText: currency,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    final int value = int.tryParse(controller.text.trim()) ?? 0;
                    Navigator.of(sheetContext).pop(value * 100);
                  },
                  child: const Text('SAVE BUDGET'),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (picked != null && picked > 0) onBudgetChanged(picked);
  }

  Future<void> _confirmReset(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset all data?'),
          content: const Text(
            'Every entry from this week will be cleared. This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppPalette.danger,
              ),
              child: const Text('RESET'),
            ),
          ],
        );
      },
    );
    if (yes ?? false) onReset();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      asset: AppAssets.bgMenu,
      overlay: <Color>[
        const Color(0xFFF8F4FA).withValues(alpha: 0.93),
        const Color(0xFFEFE7F2).withValues(alpha: 0.90),
      ],
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            ScreenHeader(title: 'SETTINGS', onBack: onBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: <Widget>[
                  _SettingsCard(
                    child: InkWell(
                      onTap: () => _editBudget(context),
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 56,
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.savings_rounded,
                                size: 24, color: AppPalette.primary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Weekly budget',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              formatMinor(weeklyBudgetMinor,
                                  symbol: currency),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.primary,
                                fontFeatures: kTabularFigures,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const _CardLabel(
                          icon: Icons.payments_rounded,
                          text: 'Currency',
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          segments: const <ButtonSegment<String>>[
                            ButtonSegment<String>(
                                value: '₽', label: Text('₽')),
                            ButtonSegment<String>(
                                value: r'$', label: Text(r'$')),
                            ButtonSegment<String>(
                                value: '€', label: Text('€')),
                          ],
                          selected: <String>{currency},
                          showSelectedIcon: false,
                          onSelectionChanged: (Set<String> next) =>
                              onCurrencyChanged(next.first),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const _CardLabel(
                          icon: Icons.calendar_today_rounded,
                          text: 'Week starts on',
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(
                          segments: const <ButtonSegment<bool>>[
                            ButtonSegment<bool>(
                                value: true, label: Text('MON')),
                            ButtonSegment<bool>(
                                value: false, label: Text('SUN')),
                          ],
                          selected: <bool>{weekStartsMonday},
                          showSelectedIcon: false,
                          onSelectionChanged: (Set<bool> next) =>
                              onWeekStartChanged(next.first),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: InkWell(
                      onTap: () => _confirmReset(context),
                      borderRadius: BorderRadius.circular(16),
                      child: const SizedBox(
                        height: 56,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete_outline_rounded,
                                size: 24, color: AppPalette.danger),
                            SizedBox(width: 12),
                            Text(
                              'Reset all data',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(
                    child: Text(
                      'Budget Bloom · v1.0.0 · offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPalette.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 24, color: AppPalette.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}
