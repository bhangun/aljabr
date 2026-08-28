import 'package:flutter/material.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../common/status_badge.dart';

/// One row in the sidebar session list/tree. Shows title, relative time,
/// a colored status dot, and (if any) how many files the session touched.
class SessionTile extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const SessionTile({super.key, required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = session.isSelected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.sidebarSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              StatusBadge(status: session.status, compact: true),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimary.withValues(alpha: 0.85),
                        fontSize: 13.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          session.status.label,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                        if (session.filesChanged > 0) ...[
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                          Text(
                            '${session.filesChanged} files',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (session.timeAgo.isNotEmpty)
                Text(
                  session.timeAgo,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
