/// App-wide constants — single source of truth.
class AppConstants {
  AppConstants._();

  static const String appName = 'CodexAgent';
  static const String appVersion = '2.0.0';

  // Storage keys
  static const String kSessions = 'sessions_v2';
  static const String kSettings = 'settings_v2';
  static const String kSnippets = 'snippets_v1';

  // Claude API
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String defaultModel = 'claude-sonnet-4-6';
  static const String anthropicVersion = '2023-06-01';
  static const int defaultMaxTokens = 8192;

  // Context window sizes per model (approximate)
  static const Map<String, int> modelContextWindows = {
    'claude-opus-4-6': 200000,
    'claude-sonnet-4-6': 200000,
    'claude-haiku-4-5': 200000,
  };

  // UI layout
  static const double sidebarWidth = 270.0;
  static const double minChatWidth = 380.0;
  static const double wideBreakpoint = 960.0;
  static const double ultraWideBreakpoint = 1280.0;

  // Heuristic: ~3 chars per token
  static int estimateTokens(String text) => (text.length / 3).ceil();
}
