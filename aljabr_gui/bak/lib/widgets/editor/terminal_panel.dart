import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_providers.dart';
import '../../theme/app_colors.dart';

/// The "Terminal" tab: read-only scrolling log of the shell commands the
/// agent has run, styled like a dark terminal buffer.
class TerminalPanel extends ConsumerWidget {
  const TerminalPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(terminalLogProvider);

    return Container(
      color: const Color(0xFF0F0F0F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Icon(Icons.terminal, size: 15, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Text(
                  'mvn quarkus:dev -Dquarkus.http.port=8086',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: log.length,
              itemBuilder: (context, i) {
                final line = log[i];
                final isPrompt = line.startsWith(r'$');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: isPrompt
                          ? AppTheme.accentGreen
                          : AppTheme.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
