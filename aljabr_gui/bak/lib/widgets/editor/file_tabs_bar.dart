import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_providers.dart';
import '../../theme/app_colors.dart';

/// Row of closable file tabs above the source view, like open buffers in
/// a code editor. Tapping a tab makes it active; the x closes it (and
/// falls back to the next open file, or a placeholder if none remain).
class FileTabsBar extends ConsumerWidget {
  const FileTabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openFiles = ref.watch(openFilesProvider);
    final activePath = ref.watch(activeFileProvider);

    return Container(
      height: 38,
      color: AppTheme.panel,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final path in openFiles)
            _FileTab(
              path: path,
              fileName: path.split('/').last,
              isActive: path == activePath,
              onTap: () => ref.read(activeFileProvider.notifier).select(path),
              onClose: () {
                ref.read(openFilesProvider.notifier).close(path);
                final remaining = ref.read(openFilesProvider);
                if (activePath == path && remaining.isNotEmpty) {
                  ref.read(activeFileProvider.notifier).select(remaining.first);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _FileTab extends StatelessWidget {
  final String path;
  final String fileName;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _FileTab({
    required this.path,
    required this.fileName,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.panelAlt : Colors.transparent,
          border: Border(
            right: const BorderSide(color: AppTheme.border),
            bottom: BorderSide(
              color: isActive ? AppTheme.accentBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(fileName), size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              fileName,
              style: TextStyle(
                color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(10),
              child: const Icon(
                Icons.close,
                size: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    if (name.endsWith('.properties')) return Icons.settings_outlined;
    if (name.endsWith('.yml') || name.endsWith('.yaml'))
      return Icons.data_object;
    if (name.endsWith('.sql')) return Icons.storage_outlined;
    return Icons.description_outlined;
  }
}
