import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Shows a reference card of all keyboard shortcuts. Triggered from the
/// settings screen.
Future<void> showShortcutsHelp(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _ShortcutsDialog(),
  );
}

class _ShortcutsDialog extends StatelessWidget {
  const _ShortcutsDialog();

  static const _shortcuts = [
    ('New session', 'Ctrl/⌘ + N'),
    ('Command palette', 'Ctrl/⌘ + K'),
    ('Toggle sidebar', 'Ctrl/⌘ + \\'),
    ('Send message', 'Enter'),
    ('New line in message', 'Shift + Enter'),
    ('Edit a message', 'Double-click it'),
    ('Slash commands', 'Type / in the input'),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: const Text('Keyboard shortcuts', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _shortcuts
              .map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(s.$1, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppTheme.border, width: 0.5),
                          ),
                          child: Text(s.$2,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 11.5, fontFamily: 'JetBrains Mono')),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: AppTheme.accent)),
        ),
      ],
    );
  }
}
