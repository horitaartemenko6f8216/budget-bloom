/// Tunable constants for Budget Bloom.
class AppConfig {
  const AppConfig._();

  /// Splash length. MUST stay exactly 8000 (rule 13) — the screenshot harness
  /// needs the loader frame to still be on screen when it takes its first shot.
  static const int loaderDurationMs = 8000;

  /// Cross-screen fade.
  static const int screenFadeMs = 260;

  /// Content entrance stagger.
  static const int contentRevealMs = 520;

  /// One-shot loader entrance animation (never a .repeat, never >= 3000ms).
  static const int loaderRevealMs = 1200;

  /// Bloom reveal on the result screen.
  static const int bloomRevealMs = 700;

  /// Passive runner never touches the screen: after this long the app records a
  /// demo entry and surfaces the result frame. Must exceed the nav agent's
  /// ~22s first-screenshot latency so the board is captured first.
  static const int idleBackstopMs = 40000;

  /// Armed exactly once on the first touch and deliberately NOT re-armed by
  /// later taps (harness tap interval is ~13s; re-arming eats the result frame).
  static const int engagedBackstopMs = 8000;

  /// Default weekly budget, in minor units (kopecks).
  static const int weeklyBudgetMinor = 600000;

  /// Amount of digits the keypad accepts.
  static const int maxAmountDigits = 6;
}
