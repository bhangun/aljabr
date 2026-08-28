import 'package:flutter/material.dart';
import '../../models/chat_entry.dart';
import '../../../../theme/app_colors.dart';

class SearchBubble extends StatelessWidget {
  final ChatEntry entry;
  const SearchBubble({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Searched for: ',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              entry.text.trim(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
