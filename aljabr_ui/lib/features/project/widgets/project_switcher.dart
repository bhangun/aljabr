import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_project_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/project_list_provider.dart';
import '../models/project.dart';
import '../../../theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';

class ProjectSwitcher extends ConsumerStatefulWidget {
  final VoidCallback? onProjectChanged;

  const ProjectSwitcher({
    super.key,
    this.onProjectChanged,
  });

  @override
  ConsumerState<ProjectSwitcher> createState() => _ProjectSwitcherState();
}

class _ProjectSwitcherState extends ConsumerState<ProjectSwitcher> {
  bool _isCreating = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectListProvider);
    final activeProject = ref.watch(activeProjectProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: _ProjectDropdown(
              projects: projects,
              selectedId: activeProject?.id,
              onChanged: (projectId) {
                if (projectId == '_no_project') {
                  ref.read(activeProjectIdProvider.notifier).setId(null);
                  ref
                      .read(activeSessionIdProvider.notifier)
                      .select(kGeneralSessionId);
                } else {
                  ref.read(activeProjectIdProvider.notifier).setId(projectId);
                }
                widget.onProjectChanged?.call();
              },
              onCreateNew: () => _showCreateProjectDialog(context),
              onDeleteProject: (projectId) =>
                  _confirmDeleteProject(context, projectId),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () {
              ref.read(projectListProvider.notifier).refresh();
            },
            tooltip: 'Refresh Projects',
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, String projectId) {
    final projects = ref.read(projectListProvider);
    final project = projects.where((p) => p.id == projectId).firstOrNull;
    if (project == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Delete Project',
            style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${project.name}"? All sessions will also be removed locally.',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(projectListProvider.notifier).deleteProject(projectId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) async {
    bool wasCancelled = false;
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        wasCancelled = true;
      } else if (selectedDirectory.isNotEmpty) {
        final name = selectedDirectory.split(RegExp(r'[\\/]')).last;
        _nameController.text = name.isNotEmpty ? name : 'New Project';
        _pathController.text = selectedDirectory;
        _createProject(context);
        return;
      }
    } catch (_) {}

    if (wasCancelled) return;

    _nameController.clear();
    _pathController.clear();

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'My Awesome Project',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathController,
                    decoration: const InputDecoration(
                      labelText: 'Root Path (optional)',
                      hintText: '/path/to/project',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'Select Directory',
                  onPressed: () async {
                    String? selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null) {
                      _pathController.text = selectedDirectory;
                      if (_nameController.text.isEmpty) {
                        // Optional: auto-fill project name from directory name
                        final dirName =
                            selectedDirectory.split(RegExp(r'[\\/]')).last;
                        if (dirName.isNotEmpty) {
                          _nameController.text = dirName;
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isCreating ? null : () => _createProject(context),
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a project name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final notifier = ref.read(projectListProvider.notifier);
      final project = await notifier.createProject(
        _nameController.text.trim(),
        '',
        _pathController.text.trim().isNotEmpty
            ? _pathController.text.trim()
            : '/',
      );

      ref.read(activeProjectIdProvider.notifier).setId(project.id);
      widget.onProjectChanged?.call();
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" created'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

class _ProjectDropdown extends StatelessWidget {
  final List<Project> projects;
  final String? selectedId;
  final Function(String) onChanged;
  final VoidCallback onCreateNew;
  final Function(String) onDeleteProject;

  const _ProjectDropdown({
    required this.projects,
    required this.selectedId,
    required this.onChanged,
    required this.onCreateNew,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isNoProject = selectedId == null || selectedId!.isEmpty;
    final Project? selected = isNoProject
        ? null
        : projects.where((p) => p.id == selectedId).firstOrNull ??
            (projects.isNotEmpty ? projects.first : null);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 44),
        onSelected: (value) {
          if (value == '_create_new') {
            onCreateNew();
          } else if (value.startsWith('_delete_')) {
            onDeleteProject(value.replaceFirst('_delete_', ''));
          } else {
            onChanged(value);
          }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[];

          // "No Project" option at top
          items.add(
            PopupMenuItem<String>(
              value: '_no_project',
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 16,
                      color: isNoProject
                          ? theme.colorScheme.primary
                          : AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No Project (General Chat)',
                      style: TextStyle(
                        fontWeight:
                            isNoProject ? FontWeight.w700 : FontWeight.normal,
                        color: isNoProject ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                  if (isNoProject)
                    Icon(Icons.check,
                        size: 16, color: theme.colorScheme.primary),
                ],
              ),
            ),
          );

          if (projects.isNotEmpty) {
            items.add(const PopupMenuDivider());
          }

          for (final project in projects) {
            items.add(
              PopupMenuItem<String>(
                value: project.id,
                child: Row(
                  children: [
                    Icon(
                      project.isArchived ? Icons.archive : Icons.folder,
                      size: 16,
                      color: project.isArchived
                          ? Colors.grey
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.name,
                        style: TextStyle(
                          fontWeight: project.id == selectedId
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (project.id == selectedId)
                      Icon(Icons.check,
                          size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onDeleteProject(project.id);
                      },
                      child: const Icon(Icons.delete_outline,
                          size: 15, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              value: '_create_new',
              child: Row(
                children: [
                  Icon(Icons.add_circle,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Create New Project'),
                ],
              ),
            ),
          );

          return items;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isNoProject
                    ? Icons.chat_bubble_outline
                    : selected?.isArchived == true
                        ? Icons.archive
                        : Icons.folder,
                size: 16,
                color: isNoProject
                    ? theme.colorScheme.primary
                    : selected?.isArchived == true
                        ? Colors.grey
                        : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isNoProject
                      ? 'No Project (General Chat)'
                      : selected?.name ?? 'Select Project',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
