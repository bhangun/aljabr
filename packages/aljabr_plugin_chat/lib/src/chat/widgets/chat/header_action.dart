import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'checkpoint_menu_button.dart';
import '../button/fork_button.dart';
import '../button/open_ide_button.dart';

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
            var activeProjectId = ref.read(activeProjectIdProvider);
            if (activeProjectId == null || activeProjectId.isEmpty) {
              final projects = ref.read(projectListProvider);
              if (projects.isNotEmpty) {
                activeProjectId = projects.first.id;
                ref.read(activeProjectIdProvider.notifier).setId(activeProjectId);
              } else {
                final defaultPath = Platform.environment['HOME'] ?? Directory.current.path;
                final created = await ref.read(projectListProvider.notifier).createProject(
                  'Wayang Platform',
                  'Default Workspace',
                  defaultPath,
                );
                activeProjectId = created.id;
                ref.read(activeProjectIdProvider.notifier).setId(activeProjectId);
              }
            }

            final title =
                'Session ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
            await ref
                .read(sessionListProvider.notifier)
                .createSession(activeProjectId, title);

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening system logs...')),
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
