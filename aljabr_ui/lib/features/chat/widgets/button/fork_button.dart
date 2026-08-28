import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../project/providers/session_actions.dart';

class ForkButton extends ConsumerWidget {
  const ForkButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Fork this session',
      child: IconButton(
        onPressed: () => forkActiveSession(ref),
        icon: const Icon(Icons.call_split,
            size: 17, color: AppTheme.textSecondary),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
