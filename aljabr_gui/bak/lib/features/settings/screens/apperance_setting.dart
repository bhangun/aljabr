// appearance_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

// ============ PROVIDERS ============
final appearanceSettingsProvider =
    StateNotifierProvider<AppearanceSettingsNotifier, AppearanceSettings>((
      ref,
    ) {
      return AppearanceSettingsNotifier();
    });

class AppearanceSettingsNotifier extends StateNotifier<AppearanceSettings> {
  AppearanceSettingsNotifier()
    : super(
        const AppearanceSettings(
          themeMode: ThemeMode.system,
          verboseAgentChat: true,
          conversationWidth: ConversationWidth.defaultWidth,
          lightTheme: LightThemePreset.defaultLight,
          darkTheme: DarkThemePreset.defaultDark,
        ),
      );

  void updateThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void updateVerboseAgentChat(bool enabled) {
    state = state.copyWith(verboseAgentChat: enabled);
  }

  void updateConversationWidth(ConversationWidth width) {
    state = state.copyWith(conversationWidth: width);
  }

  void updateLightTheme(LightThemePreset preset) {
    state = state.copyWith(lightTheme: preset);
  }

  void updateDarkTheme(DarkThemePreset preset) {
    state = state.copyWith(darkTheme: preset);
  }
}

// ============ MODELS ============
enum ThemeMode { light, dark, system }

enum ConversationWidth { defaultWidth, narrow, wide, full }

enum LightThemePreset { defaultLight, solarizedLight, githubLight, custom }

enum DarkThemePreset { defaultDark, dracula, monokai, solarizedDark, custom }

class AppearanceSettings {
  final ThemeMode themeMode;
  final bool verboseAgentChat;
  final ConversationWidth conversationWidth;
  final LightThemePreset lightTheme;
  final DarkThemePreset darkTheme;

  const AppearanceSettings({
    required this.themeMode,
    required this.verboseAgentChat,
    required this.conversationWidth,
    required this.lightTheme,
    required this.darkTheme,
  });

  AppearanceSettings copyWith({
    ThemeMode? themeMode,
    bool? verboseAgentChat,
    ConversationWidth? conversationWidth,
    LightThemePreset? lightTheme,
    DarkThemePreset? darkTheme,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      verboseAgentChat: verboseAgentChat ?? this.verboseAgentChat,
      conversationWidth: conversationWidth ?? this.conversationWidth,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

// ============ MAIN WIDGET ============
class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends ConsumerState<AppearanceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerboseAgentChatSection(),
            SizedBox(height: 24),
            ConversationWidthSection(),
            SizedBox(height: 24),
            ThemeModeSection(),
            SizedBox(height: 24),
            LightThemeSection(),
            SizedBox(height: 24),
            DarkThemeSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}

// ============ VERBOSE AGENT CHAT SECTION ============
class VerboseAgentChatSection extends ConsumerWidget {
  const VerboseAgentChatSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);

    return _buildSection(
      title: 'Verbose Agent Chat',
      subtitle: 'Display and preserve intermediate thinking steps.',
      child: SwitchListTile(
        value: settings.verboseAgentChat,
        onChanged: (value) {
          ref
              .read(appearanceSettingsProvider.notifier)
              .updateVerboseAgentChat(value);
        },
        title: const Text('Enable verbose mode'),
        activeColor: Colors.blue,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

// ============ CONVERSATION WIDTH SECTION ============
class ConversationWidthSection extends ConsumerWidget {
  const ConversationWidthSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);

    return _buildSection(
      title: 'Conversation Width',
      subtitle: 'Configure the maximum width of the conversation panel.',
      child: Column(
        children: [
          _buildRadioOption(
            value: ConversationWidth.defaultWidth,
            groupValue: settings.conversationWidth,
            label: 'Default',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateConversationWidth(value!);
            },
          ),
          _buildRadioOption(
            value: ConversationWidth.narrow,
            groupValue: settings.conversationWidth,
            label: 'Narrow',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateConversationWidth(value!);
            },
          ),
          _buildRadioOption(
            value: ConversationWidth.wide,
            groupValue: settings.conversationWidth,
            label: 'Wide',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateConversationWidth(value!);
            },
          ),
          _buildRadioOption(
            value: ConversationWidth.full,
            groupValue: settings.conversationWidth,
            label: 'Full',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateConversationWidth(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ THEME MODE SECTION ============
class ThemeModeSection extends ConsumerWidget {
  const ThemeModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);

    return _buildSection(
      title: 'Appearance',
      subtitle: 'Select light, dark, or inherit system settings.',
      child: Column(
        children: [
          _buildRadioOption(
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            label: 'Light',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateThemeMode(value!);
            },
          ),
          _buildRadioOption(
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            label: 'Dark',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateThemeMode(value!);
            },
          ),
          _buildRadioOption(
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            label: 'System',
            onChanged: (value) {
              ref
                  .read(appearanceSettingsProvider.notifier)
                  .updateThemeMode(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ LIGHT THEME SECTION ============
class LightThemeSection extends ConsumerWidget {
  const LightThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);

    return _buildSection(
      title: 'Light Theme',
      subtitle: 'Configure light theme appearance.',
      child: Column(
        children: [
          _buildThemePresetTile(
            label: 'Preset',
            value: settings.lightTheme.name,
            onTap: () => _showLightThemePicker(context, ref),
          ),
          const Divider(height: 1),
          _buildColorRow(label: 'Background', color: Colors.grey[200]!),
          _buildColorRow(label: 'Foreground', color: Colors.grey[900]!),
          _buildColorRow(label: 'Accent', color: Colors.blue[700]!),
        ],
      ),
    );
  }

  void _showLightThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: LightThemePreset.values.map((preset) {
            return ListTile(
              title: Text(preset.name.replaceAll('_', ' ').toTitleCase()),
              onTap: () {
                ref
                    .read(appearanceSettingsProvider.notifier)
                    .updateLightTheme(preset);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============ DARK THEME SECTION ============
class DarkThemeSection extends ConsumerWidget {
  const DarkThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsProvider);

    return _buildSection(
      title: 'Dark Theme',
      subtitle: 'Configure dark theme appearance.',
      child: Column(
        children: [
          _buildThemePresetTile(
            label: 'Preset',
            value: settings.darkTheme.name,
            onTap: () => _showDarkThemePicker(context, ref),
          ),
          const Divider(height: 1),
          _buildColorRow(label: 'Background', color: Colors.grey[850]!),
          _buildColorRow(label: 'Foreground', color: Colors.grey[300]!),
          _buildColorRow(label: 'Accent', color: Colors.blue[400]!),
        ],
      ),
    );
  }

  void _showDarkThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DarkThemePreset.values.map((preset) {
            return ListTile(
              title: Text(preset.name.replaceAll('_', ' ').toTitleCase()),
              onTap: () {
                ref
                    .read(appearanceSettingsProvider.notifier)
                    .updateDarkTheme(preset);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============ PROVIDE FEEDBACK BUTTON ============
class ProvideFeedbackButton extends StatelessWidget {
  const ProvideFeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigate to feedback
        },
        icon: const Icon(Icons.feedback_outlined, size: 18),
        label: const Text('Provide Feedback'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

// ============ HELPER WIDGETS ============
Widget _buildSection({
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: child,
      ),
    ],
  );
}

Widget _buildRadioOption<T>({
  required T value,
  required T groupValue,
  required String label,
  required ValueChanged<T?> onChanged,
}) {
  return RadioListTile<T>(
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
    visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
    activeColor: Colors.blue,
  );
}

Widget _buildThemePresetTile({
  required String label,
  required String value,
  required VoidCallback onTap,
}) {
  return ListTile(
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.replaceAll('_', ' ').toTitleCase(),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
      ],
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
    onTap: onTap,
  );
}

Widget _buildColorRow({required String label, required Color color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _colorToHex(color),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

// ============ EXTENSIONS ============
extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
