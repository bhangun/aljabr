import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../theme/app_colors.dart';

class SuggestionsList extends StatelessWidget {
  final String trigger;
  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  const SuggestionsList({
    super.key,
    required this.trigger,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions
            .map((s) => _SuggestionItem(
                  trigger: trigger,
                  suggestion: s,
                  onTap: () => onSelect(s),
                ))
            .toList(),
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final String trigger;
  final String suggestion;
  final VoidCallback onTap;

  const _SuggestionItem({
    required this.trigger,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              trigger == '@' ? Icons.description_outlined : Icons.bolt,
              size: 14,
              color: AppTheme.textMuted,
            ),
            const Gap(8),
            Expanded(
              child: Text(
                suggestion,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
