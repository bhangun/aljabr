import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../providers/session_list_provider.dart';
import '../../../theme/app_colors.dart';
import '../models/session_statusx.dart';

/// One row in the sidebar session list/tree. Shows title, status, and a delete action.
class SessionTile extends ConsumerStatefulWidget {
  final Session session;
  final VoidCallback onTap;

  const SessionTile({super.key, required this.session, required this.onTap});

  @override
  ConsumerState<SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends ConsumerState<SessionTile> {
  bool _isHovered = false;

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.session.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Rename Session',
            style: TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Session title',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            isDense: true,
            filled: true,
            fillColor: AppTheme.panelAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ref
                  .read(sessionListProvider.notifier)
                  .renameSession(widget.session.id, val.trim());
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                ref
                    .read(sessionListProvider.notifier)
                    .renameSession(widget.session.id, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Delete Session',
            style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${widget.session.title}"?',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(sessionListProvider.notifier)
                  .deleteSession(widget.session.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.session.isSelected;
    final isArchived = widget.session.status == SessionStatus.archived;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          onDoubleTap: () => _showRenameDialog(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.sidebarSelected : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Status indicator - small dot
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isArchived
                        ? AppTheme.textMuted
                        : widget.session.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isArchived
                              ? AppTheme.textMuted
                              : selected
                                  ? AppTheme.textPrimary
                                  : AppTheme.textPrimary
                                      .withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          decoration:
                              isArchived ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.session.status.label,
                            style: TextStyle(
                              color: isArchived
                                  ? AppTheme.textMuted
                                  : widget.session.status.color,
                              fontSize: 11,
                            ),
                          ),
                          if (widget.session.fileChanges > 0) ...[
                            const Text(' · ',
                                style: TextStyle(
                                    color: AppTheme.textMuted, fontSize: 11)),
                            Text('${widget.session.fileChanges} files',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 11)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isHovered || selected) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 14, color: AppTheme.textMuted),
                    tooltip: 'Rename Session',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                    onPressed: () => _showRenameDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 14, color: AppTheme.textMuted),
                    tooltip: 'Delete Chat',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                    onPressed: () => _confirmDelete(context),
                  ),
                ] else if (widget.session.timeAgo.isNotEmpty)
                  Text(
                    widget.session.timeAgo,
                    style: TextStyle(
                      color: isArchived
                          ? AppTheme.textMuted.withValues(alpha: 0.5)
                          : AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
