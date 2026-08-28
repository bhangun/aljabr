import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../providers/active_project_provider.dart';
import '../providers/project_list_provider.dart';

class NewProjectButton extends ConsumerWidget {
  const NewProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        bool wasCancelled = false;
        try {
          String? selectedDirectory =
              await FilePicker.platform.getDirectoryPath();

          if (selectedDirectory == null) {
            wasCancelled = true;
          } else if (selectedDirectory.isNotEmpty) {
            final name = selectedDirectory.split(Platform.pathSeparator).last;
            final notifier = ref.read(projectListProvider.notifier);
            final project = await notifier.createProject(
              name.isNotEmpty ? name : 'New Project',
              '',
              selectedDirectory,
            );

            ref.read(activeProjectIdProvider.notifier).setId(project.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Project "${project.name}" opened'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return;
          }
        } catch (_) {}

        if (wasCancelled) return;

        // Fallback dialog if native picker not available
        if (context.mounted) {
          _showManualPathDialog(context, ref);
        }
      },
      icon: const Icon(Icons.create_new_folder_outlined,
          size: 16, color: AppTheme.textPrimary),
      label: const Text('New Project',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _showManualPathDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: 'My Project');
    final pathCtrl = TextEditingController(text: Directory.current.path);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Add / Open Project',
            style: TextStyle(fontSize: 16, color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pathCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Root Directory Path',
                hintText: '/path/to/project',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final path = pathCtrl.text.trim();
              if (name.isEmpty || path.isEmpty) return;

              final notifier = ref.read(projectListProvider.notifier);
              final project = await notifier.createProject(name, '', path);
              ref.read(activeProjectIdProvider.notifier).setId(project.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add Project'),
          ),
        ],
      ),
    );
  }
}
