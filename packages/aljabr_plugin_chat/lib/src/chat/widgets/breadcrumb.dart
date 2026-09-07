import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class Breadcrumb extends ConsumerWidget {
  final Project project;
  final Session session;
  const Breadcrumb({super.key, required this.project, required this.session});

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: session.title);
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
                  .renameSession(session.id, val.trim());
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
                    .renameSession(session.id, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Icon(Icons.folder_open, size: 16, color: AppTheme.textSecondary),
        const Gap(8),
        Text(
          project.name,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const Gap(6),
        const Icon(Icons.chevron_right, size: 14, color: AppTheme.textMuted),
        const Gap(6),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _showRenameDialog(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                const Icon(Icons.edit_outlined,
                    size: 12, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
