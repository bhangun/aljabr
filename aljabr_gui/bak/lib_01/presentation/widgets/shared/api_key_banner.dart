import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/settings/states/settings_provider.dart';
import '../../../features/settings/screens/settings_screen.dart';

/// Slim dismissible-by-action banner prompting the user to set up their
/// Anthropic API key. Shown above the message list when missing.
class ApiKeyBanner extends ConsumerWidget {
  const ApiKeyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasKey = ref.watch(settingsProvider.select((s) => s.hasApiKey));
    if (hasKey) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.08),
        border: const Border(
          bottom: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_outlined, size: 15, color: AppTheme.warning),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Add your Anthropic API key to start chatting.',
              style: TextStyle(color: AppTheme.warning, fontSize: 12.5),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: const Text(
              'Open settings →',
              style: TextStyle(
                color: AppTheme.warning,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
