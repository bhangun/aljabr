import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class UsageChip extends StatelessWidget {
  final int tokens;
  final double costUsd;
  const UsageChip({super.key, required this.tokens, required this.costUsd});

  @override
  Widget build(BuildContext context) {
    final tokenLabel =
        tokens >= 1000 ? '${(tokens / 1000).toStringAsFixed(1)}K' : '$tokens';
    return Tooltip(
      message: 'Estimated tokens and cost for this session',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.query_stats,
            size: 13,
            color: AppTheme.textMuted,
          ),
          const Gap(4),
          Text(
            '$tokenLabel tokens · \$${costUsd.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
