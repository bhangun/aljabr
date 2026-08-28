import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/chat/models/session.dart';
import '../../../features/chat/states/chat_provider.dart';
import '../../../features/chat/states/projects_provider.dart';
import '../../../features/chat/states/sessions_provider.dart';
import '../../../features/settings/states/settings_provider.dart';
import '../command_palette/command_palette.dart';
import '../shared/shared_widgets.dart';

class SessionSidebar extends ConsumerStatefulWidget {
  const SessionSidebar({super.key});

  @override
  ConsumerState<SessionSidebar> createState() => _SessionSidebarState();
}

class _SessionSidebarState extends ConsumerState<SessionSidebar> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final settings = ref.watch(settingsProvider);

    final filtered = _query.isEmpty
        ? sessions
        : sessions
              .where(
                (s) => s.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    final pinned = filtered.where((s) => s.isPinned).toList();
    final recents = filtered.where((s) => !s.isPinned).toList();

    return Container(
      width: 280,
      color: AppTheme.surface,
      child: Column(
        children: [
          _ProjectSelector(hasApiKey: settings.hasApiKey),
          const CodexDivider(),
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            onCommandPalette: () => showCommandPalette(context),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: sessions.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    message: 'No sessions yet',
                    subtitle: 'Start a new conversation',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        const SectionHeader(
                          title: 'Pinned',
                          icon: Icons.push_pin_outlined,
                        ),
                        ...pinned.map(
                          (s) => _SessionTile(
                            session: s,
                            isActive: s.id == activeSession?.id,
                          ),
                        ),
                      ],
                      if (recents.isNotEmpty) ...[
                        if (pinned.isNotEmpty) const SizedBox(height: 8),
                        const SectionHeader(
                          title: 'Recent',
                          icon: Icons.history,
                        ),
                        ...recents.map(
                          (s) => _SessionTile(
                            session: s,
                            isActive: s.id == activeSession?.id,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          const CodexDivider(),
          _SidebarFooter(sessionCount: sessions.length),
          _NewSessionButton(),
        ],
      ),
    );
  }
}

class _ProjectSelector extends ConsumerWidget {
  const _ProjectSelector({required this.hasApiKey});
  final bool hasApiKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProject = ref.watch(activeProjectProvider);
    final projectsState = ref.watch(projectsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_open, size: 16, color: AppTheme.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: activeProject?.id,
                hint: const Text('Select Project', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                dropdownColor: AppTheme.surfaceElevated,
                icon: const Icon(Icons.expand_more, size: 16, color: AppTheme.textMuted),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  ...projectsState.projects.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      )),
                  const DropdownMenuItem(
                    value: '__new__',
                    child: Text('+ New Project', style: TextStyle(color: AppTheme.accent)),
                  ),
                ],
                onChanged: (val) async {
                  if (val == '__new__') {
                    final newName = await _promptNewProjectName(context);
                    if (newName != null && newName.isNotEmpty) {
                      ref.read(projectsProvider.notifier).createProject(name: newName);
                    }
                  } else if (val != null) {
                    ref.read(projectsProvider.notifier).setActiveProject(val);
                  }
                },
              ),
            ),
          ),
          if (!hasApiKey) ...[
            const SizedBox(width: 8),
            const Tooltip(
              message: 'API key not set',
              child: Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: AppTheme.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<String?> _promptNewProjectName(BuildContext context) {
    String name = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('New Project', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(hintText: 'Project Name'),
          onChanged: (v) => name = v,
          onSubmitted: (_) => Navigator.pop(ctx, name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, name),
            child: const Text('Create', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onCommandPalette,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCommandPalette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search sessions…',
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 7),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: 'Command palette (Ctrl/Cmd+K)',
            child: GestureDetector(
              onTap: onCommandPalette,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: const Icon(
                  Icons.keyboard_command_key,
                  size: 15,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends ConsumerStatefulWidget {
  const _SessionTile({required this.session, required this.isActive});
  final Session session;
  final bool isActive;

  @override
  ConsumerState<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends ConsumerState<_SessionTile> {
  bool _renaming = false;
  late TextEditingController _renameController;

  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController(text: widget.session.title);
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  void _commitRename() {
    final newTitle = _renameController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.session.title) {
      ref
          .read(sessionsProvider.notifier)
          .renameSession(widget.session.id, newTitle);
    }
    setState(() => _renaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final isActive = widget.isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isActive
            ? AppTheme.accent.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: _renaming
              ? null
              : () => ref.read(chatProvider.notifier).loadSession(session),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                // active indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_renaming)
                        TextField(
                          controller: _renameController,
                          autofocus: true,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _commitRename(),
                          onTapOutside: (_) => _commitRename(),
                        )
                      else ...[
                        Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? AppTheme.accent
                                : AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!_renaming)
                  _TileMenu(
                    session: session,
                    onRename: () => setState(() => _renaming = true),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileMenu extends ConsumerWidget {
  const _TileMenu({required this.session, required this.onRename});
  final Session session;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (action) async {
        switch (action) {
          case 'rename':
            onRename();
          case 'pin':
            await ref
                .read(sessionsProvider.notifier)
                .pinSession(session.id, pinned: !session.isPinned);
          case 'duplicate':
            final copy = await ref
                .read(sessionsProvider.notifier)
                .duplicateSession(session.id);
            if (copy != null) ref.read(chatProvider.notifier).loadSession(copy);
          case 'export':
            await _exportSession(context, ref, session);
          case 'delete':
            if (!context.mounted) return;
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => _ConfirmDeleteDialog(title: session.title),
            );
            if (confirmed == true) {
              ref.read(sessionsProvider.notifier).deleteSession(session.id);
              final active = ref.read(activeSessionProvider);
              if (active?.id == session.id) {
                ref.read(chatProvider.notifier).clearSession();
              }
            }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.drive_file_rename_outline, size: 15),
              SizedBox(width: 8),
              Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                session.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 15,
              ),
              const SizedBox(width: 8),
              Text(session.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy_outlined, size: 15),
              SizedBox(width: 8),
              Text('Duplicate'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.ios_share_outlined, size: 15),
              SizedBox(width: 8),
              Text('Export'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 15, color: AppTheme.error),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      ],
      color: AppTheme.surfaceElevated,
      icon: const Icon(Icons.more_vert, size: 15, color: AppTheme.textMuted),
      splashRadius: 14,
    );
  }
}

Future<void> _exportSession(
  BuildContext context,
  WidgetRef ref,
  Session session,
) async {
  final result = ref.read(sessionsProvider.notifier).exportSession(session);
  result.fold(
    onSuccess: (json) async {
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session JSON copied to clipboard'),
            backgroundColor: AppTheme.surfaceElevated,
          ),
        );
      }
    },
    onFailure: (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.message}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    },
  );
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: const Text(
        'Delete session',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      content: Text(
        'Delete "$title"? This cannot be undone.',
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
        ),
      ],
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter({required this.sessionCount});
  final int sessionCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Text(
            '$sessionCount session${sessionCount == 1 ? '' : 's'}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _importSession(context, ref),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.file_download_outlined,
                  size: 13,
                  color: AppTheme.textMuted,
                ),
                SizedBox(width: 3),
                Text(
                  'Import',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importSession(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final jsonString = String.fromCharCodes(result.files.single.bytes!);
    final importResult = await ref
        .read(sessionsProvider.notifier)
        .importFromJson(jsonString);

    if (!context.mounted) return;
    importResult.fold(
      onSuccess: (sessions) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${sessions.length} session${sessions.length == 1 ? '' : 's'}',
            ),
            backgroundColor: AppTheme.surfaceElevated,
          ),
        );
      },
      onFailure: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: ${e.message}'),
            backgroundColor: AppTheme.error,
          ),
        );
      },
    );
  }
}

class _NewSessionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: CodexButton(
          label: 'New session',
          icon: Icons.add,
          variant: ButtonVariant.secondary,
          onPressed: () async {
            final session = await ref
                .read(sessionsProvider.notifier)
                .createSession();
            ref.read(chatProvider.notifier).loadSession(session);
          },
        ),
      ),
    );
  }
}
