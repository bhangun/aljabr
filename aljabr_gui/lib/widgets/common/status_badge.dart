import 'package:flutter/material.dart';

import '../../features/project/models/session_statusx.dart';
import '../../theme/app_colors.dart';

/// Small colored pill used anywhere a [SessionStatus] needs to be shown:
/// sidebar tiles, chat header, session switcher.
class StatusBadge extends StatelessWidget {
  final SessionStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    if (compact) {
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SessionStatus.running)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.6, color: color),
            )
          else
            Icon(status.icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small "+A -D" file-change stat chip used on session tiles and diff cards.
class DiffStatChip extends StatelessWidget {
  final int additions;
  final int deletions;
  const DiffStatChip(
      {super.key, required this.additions, required this.deletions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('+$additions',
            style: const TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 11.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text('-$deletions',
            style: const TextStyle(
                color: Color(0xFFE0554C),
                fontSize: 11.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
