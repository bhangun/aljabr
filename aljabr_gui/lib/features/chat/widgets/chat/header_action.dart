import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../project/providers/active_project_provider.dart';
import '../../../project/providers/active_session_provider.dart';
import '../../../project/providers/session_list_provider.dart';
import 'checkpoint_menu_button.dart';
import '../button/fork_button.dart';
import '../button/open_ide_button.dart';
import '../../../log/widgets/log_view_dialog.dart';

class HeaderActions extends ConsumerWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          tooltip: 'New Chat',
          icon: const Icon(Icons.add, size: 20),
          onPressed: () async {
            final activeProjectId = ref.read(activeProjectIdProvider);
            final title =
                'Session ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
            await ref
                .read(sessionListProvider.notifier)
                .createSession(activeProjectId!, title);

            final sessions = ref.read(sessionListProvider);
            if (sessions.isNotEmpty) {
              final newSession = sessions.last;
              ref.read(activeSessionIdProvider.notifier).select(newSession.id);
            }
          },
        ),
        IconButton(
          tooltip: 'View Logs',
          icon: const Icon(Icons.terminal, size: 18),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const LogViewDialog(),
            );
          },
        ),
        const ForkButton(),
        const CheckpointMenuButton(),
        const Gap(6),
        const OpenIdeButton(),
      ],
    );
  }
}
