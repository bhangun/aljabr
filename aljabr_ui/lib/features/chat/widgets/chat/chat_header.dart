import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../widgets/common/status_badge.dart';
import '../../../project/providers/active_project_provider.dart';
import '../../../project/providers/active_session_provider.dart';
import '../breadcrumb.dart';
import 'header_action.dart';

/// Chat header with project/session info, status, and actions

class ChatHeader extends ConsumerWidget {
  @Preview(
    name: 'Chat Header',
  )
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(activeProjectProvider);
    final session = ref.watch(activeSessionProvider);

    if (project == null || session == null) {
      return const SizedBox(height: 52);
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Breadcrumb(project: project, session: session),
          const Gap(10),
          StatusBadge(status: session.status),
          const Spacer(),
          const HeaderActions(),
        ],
      ),
    );
  }
}
