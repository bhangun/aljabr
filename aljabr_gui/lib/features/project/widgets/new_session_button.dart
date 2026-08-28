import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../providers/active_project_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/session_list_provider.dart';

class NewSessionButton extends ConsumerWidget {
  const NewSessionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        final activeProjectId = ref.read(activeProjectIdProvider);
        if (activeProjectId == null || activeProjectId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a project first'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final title =
            'Session ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        final notifier = ref.read(sessionListProvider.notifier);
        await notifier.createSession(activeProjectId, title);

        final sessions = ref.read(sessionListProvider);
        if (sessions.isNotEmpty) {
          final newSession = sessions.last;
          ref.read(activeSessionIdProvider.notifier).select(newSession.id);
        }
      },
      icon: const Icon(Icons.chat_bubble_outline,
          size: 16, color: AppTheme.textPrimary),
      label: const Text('New Chat',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
