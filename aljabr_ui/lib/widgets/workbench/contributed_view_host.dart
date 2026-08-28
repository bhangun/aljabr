import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../providers/module_manager_provider.dart';
import '../../theme/app_colors.dart';

class ContributedViewHost extends ConsumerWidget {
  final String viewId;

  const ContributedViewHost({
    super.key,
    required this.viewId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(viewRegistryProvider);
    final contribution = registry.get(viewId);

    if (contribution == null) {
      return Center(
        child: Text(
          'View not found: $viewId',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
      );
    }

    return contribution.builder(context);
  }
}
