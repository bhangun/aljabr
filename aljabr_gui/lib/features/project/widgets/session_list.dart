import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_statusx.dart';
import '../providers/active_project_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/project_providers.dart';
import '../models/session.dart';
import '../providers/session_list_provider.dart';

class SessionList extends ConsumerStatefulWidget {
  final VoidCallback? onSessionSelected;

  const SessionList({
    super.key,
    this.onSessionSelected,
  });

  @override
  ConsumerState<SessionList> createState() => _SessionListState();
}

class _SessionListState extends ConsumerState<SessionList> {
  bool _isCreating = false;
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProject = ref.watch(activeProjectProvider);
    final activeSessionId = ref.watch(activeSessionIdProvider);

    if (activeProject == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Project Selected',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select or create a project to get started',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final sessions = ref.watch(sessionListProvider);

    Widget content;
    if (sessions.isEmpty) {
      content = _EmptySessions(
        onCreate: () => _showCreateSessionDialog(context),
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          final isSelected = session.id == activeSessionId;
          return _SessionItem(
            session: session,
            isSelected: isSelected,
            onTap: () {
              ref.read(activeSessionIdProvider.notifier).select(session.id);
              widget.onSessionSelected?.call();
            },
            onDelete: () => _deleteSession(session.id),
            onFork: () => _forkSession(session.id),
            onArchive: () => _archiveSession(session.id),
            onPin: () => _pinSession(session.id),
            onRename: () => _renameSession(session.id, session.title),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sessions',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: _isCreating
                    ? null
                    : () => _showCreateSessionDialog(context),
                tooltip: 'New Session',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
        Expanded(
          child: content,
        ),
      ],
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    _titleController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Session'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Session Title',
            hintText: 'My New Session',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isCreating ? null : () => _createSession(context),
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

  Future<void> _createSession(BuildContext context) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a session title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final activeProject = ref.read(activeProjectProvider);
      if (activeProject == null) return;

      final notifier = ref.read(sessionListProvider.notifier);
      final session = await notifier.createSession(activeProject.id, title);

      ref.read(activeSessionIdProvider.notifier).select(session.id);
      widget.onSessionSelected?.call();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: $e'),
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

  Future<void> _renameSession(String id, String currentTitle) async {
    final renameController = TextEditingController(text: currentTitle);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(
            labelText: 'Session Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, renameController.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    renameController.dispose();

    if (newTitle != null &&
        newTitle.trim().isNotEmpty &&
        newTitle != currentTitle) {
      try {
        await ref
            .read(sessionListProvider.notifier)
            .renameSession(id, newTitle);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to rename session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteSession(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this session? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final activeProject = ref.read(activeProjectProvider);
      if (activeProject == null) return;

      final notifier = ref.read(sessionListProvider.notifier);
      await notifier.deleteSession(id);

      // Clear active session if it was deleted
      final activeId = ref.read(activeSessionIdProvider);
      if (activeId == id) {
        ref.read(activeSessionIdProvider.notifier).select('');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _forkSession(String id) async {
    try {
      final activeProject = ref.read(activeProjectProvider);
      if (activeProject == null) return;

      final notifier = ref.read(sessionListProvider.notifier);
      final session = await notifier.forkSession(id);

      ref.read(activeSessionIdProvider.notifier).select(session.id);
      widget.onSessionSelected?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fork session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _archiveSession(String id) async {
    try {
      final activeProject = ref.read(activeProjectProvider);
      if (activeProject == null) return;

      final service = ref.read(projectServiceProvider);
      final session = await service.getSession(id);

      final archived = session.copyWith(
        status: SessionStatus.archived,
        updatedAt: DateTime.now(),
      );

      await service.updateSession(archived);

      // Refresh session list
      ref.invalidate(sessionListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pinSession(String id) async {
    try {
      final activeProject = ref.read(activeProjectProvider);
      if (activeProject == null) return;

      final service = ref.read(projectServiceProvider);
      final session = await service.getSession(id);

      final updated = session.copyWith(
        isPinned: !session.isPinned,
        updatedAt: DateTime.now(),
      );

      await service.updateSession(updated);

      // Refresh session list
      ref.invalidate(sessionListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SessionItem extends StatelessWidget {
  final Session session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFork;
  final VoidCallback onArchive;
  final VoidCallback onPin;
  final VoidCallback onRename;

  const _SessionItem({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onFork,
    required this.onArchive,
    required this.onPin,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArchived = session.status == SessionStatus.archived;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Icon(
          session.status.icon,
          color: session.status.color,
          size: 16,
        ),
        title: Text(
          session.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isArchived
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              session.timeAgo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (session.fileChanges > 0) ...[
              const SizedBox(width: 8),
              Text(
                '+${session.fileChanges} files',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                ),
              ),
            ],
            if (session.messageCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                '${session.messageCount} messages',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (session.isPinned) ...[
              const SizedBox(width: 8),
              const Icon(Icons.push_pin, size: 12),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 16),
          onSelected: (value) {
            switch (value) {
              case 'rename':
                onRename();
                break;
              case 'fork':
                onFork();
                break;
              case 'pin':
                onPin();
                break;
              case 'archive':
                onArchive();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Rename Session'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fork',
              child: Row(
                children: [
                  Icon(Icons.call_split, size: 16),
                  SizedBox(width: 8),
                  Text('Fork Session'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'pin',
              child: Row(
                children: [
                  Icon(
                    session.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(session.isPinned ? 'Unpin' : 'Pin Session'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive, size: 16),
                  SizedBox(width: 8),
                  Text('Archive Session'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Session', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}

class _EmptySessions extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptySessions({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Sessions Yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new session to start chatting',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create Session'),
          ),
        ],
      ),
    );
  }
}
