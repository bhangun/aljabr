import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/project_settings_provider.dart';
import 'section_widget.dart';

class FoldersSection extends ConsumerWidget {
  const FoldersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Folders',
      subtitle: 'Manage project folders and paths.',
      child: Column(
        children: [
          ...settings.folders.map(
            (folder) => _buildFolderTile(
              folder: folder,
              onDelete: () {
                ref.read(projectSettingsProvider.notifier).removeFolder(folder);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () => _showAddFolderDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Folder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter folder path',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(projectSettingsProvider.notifier)
                    .addFolder(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTile({
    required String folder,
    required VoidCallback onDelete,
  }) {
    return ListTile(
      leading: Icon(Icons.folder, color: Colors.blue[400], size: 18),
      title: Text(
        folder,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'monospace',
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }
}
