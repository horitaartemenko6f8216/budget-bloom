import 'package:flutter/material.dart';

import 'game/expense_repository.dart';
import 'game/game_config.dart';
import 'game/models.dart';
import 'screens/categories_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

void main() {
  runApp(const BudgetBloomApp());
}

enum Screen { loader, menu, game, result, categories, settings }

class BudgetBloomApp extends StatelessWidget {
  const BudgetBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Bloom',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const BudgetBloomHome(),
    );
  }
}

class BudgetBloomHome extends StatefulWidget {
  const BudgetBloomHome({super.key});

  @override
  State<BudgetBloomHome> createState() => _BudgetBloomHomeState();
}

class _BudgetBloomHomeState extends State<BudgetBloomHome> {
  late final ExpenseRepository _repository;

  Screen _screen = Screen.loader;
  Expense? _lastEntry;
  String _currency = '₽';
  int _weeklyBudgetMinor = AppConfig.weeklyBudgetMinor;
  bool _weekStartsMonday = true;
  final Set<String> _hiddenCategories = <String>{};

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepository(seed: buildSeedExpenses());
  }

  void _go(Screen next) {
    if (!mounted || _screen == next) return;
    setState(() => _screen = next);
  }

  void _onSaved(Expense entry) {
    if (!mounted) return;
    setState(() {
      _repository.add(entry);
      _lastEntry = entry;
      _screen = Screen.result;
    });
  }

  void _resetAll() {
    if (!mounted) return;
    setState(() {
      _repository.clear();
      _lastEntry = null;
      _screen = Screen.menu;
    });
  }

  Widget _buildScreen() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onDone: () => _go(Screen.menu),
        );
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          repository: _repository,
          currency: _currency,
          onLog: () => _go(Screen.game),
          onCategories: () => _go(Screen.categories),
          onSettings: () => _go(Screen.settings),
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game_${_repository.entryCount}'),
          repository: _repository,
          currency: _currency,
          onBack: () => _go(Screen.menu),
          onSaved: _onSaved,
        );
      case Screen.result:
        return GameOverScreen(
          key: const ValueKey<String>('result'),
          repository: _repository,
          currency: _currency,
          lastEntry: _lastEntry,
          onAddAgain: () => _go(Screen.game),
          onMenu: () => _go(Screen.menu),
        );
      case Screen.categories:
        return CategoriesScreen(
          key: const ValueKey<String>('categories'),
          repository: _repository,
          currency: _currency,
          hidden: _hiddenCategories,
          onToggle: (String id, bool visible) {
            setState(() {
              if (visible) {
                _hiddenCategories.remove(id);
              } else {
                _hiddenCategories.add(id);
              }
            });
          },
          onBack: () => _go(Screen.menu),
        );
      case Screen.settings:
        return SettingsScreen(
          key: const ValueKey<String>('settings'),
          weeklyBudgetMinor: _weeklyBudgetMinor,
          currency: _currency,
          weekStartsMonday: _weekStartsMonday,
          onBudgetChanged: (int value) =>
              setState(() => _weeklyBudgetMinor = value),
          onCurrencyChanged: (String value) =>
              setState(() => _currency = value),
          onWeekStartChanged: (bool value) =>
              setState(() => _weekStartsMonday = value),
          onReset: _resetAll,
          onBack: () => _go(Screen.menu),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: AppConfig.screenFadeMs),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _buildScreen(),
      ),
    );
  }
}
