import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/chat/states/chat_provider.dart';

/// A compact pill showing the estimated fraction of the context window used.
/// Hovering/long-pressing it reveals a tooltip with the exact token estimate.
class ContextUsageIndicator extends ConsumerWidget {
  const ContextUsageIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fraction = ref.watch(contextWindowFractionProvider);
    final tokens = ref.watch(estimatedContextTokensProvider);

    final color = switch (fraction) {
      < 0.5 => AppTheme.success,
      < 0.8 => AppTheme.warning,
      _ => AppTheme.error,
    };

    return Tooltip(
      message: '~$tokens tokens estimated in context (${(fraction * 100).toStringAsFixed(0)}%)',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: fraction.clamp(0.02, 1.0),
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatTokens(tokens),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTokens(int tokens) {
    if (tokens < 1000) return '$tokens tok';
    return '${(tokens / 1000).toStringAsFixed(1)}k tok';
  }
}
