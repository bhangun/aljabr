import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../features/chat/states/chat_provider.dart';
import '../../../features/chat/states/sessions_provider.dart';
import '../../providers/snippets_provider.dart';
import '../../../features/settings/screens/settings_screen.dart';

/// A single, generic entry in the palette's result list.
class _PaletteEntry {
  const _PaletteEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSelect,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onSelect;
  final Widget? trailing;
}

/// Opens the command palette as a centered dialog. Call via
/// `showCommandPalette(context)` — typically bound to Cmd/Ctrl+K.
Future<void> showCommandPalette(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Command palette',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (_, __, ___) => const _CommandPaletteDialog(),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween(
          begin: 0.97,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    ),
  );
}

class _CommandPaletteDialog extends ConsumerStatefulWidget {
  const _CommandPaletteDialog();

  @override
  ConsumerState<_CommandPaletteDialog> createState() =>
      _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends ConsumerState<_CommandPaletteDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _highlightedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_PaletteEntry> _buildEntries(String query) {
    final q = query.toLowerCase().trim();
    final entries = <_PaletteEntry>[];

    // Actions (always available, filtered by name match)
    final actions = <_PaletteEntry>[
      _PaletteEntry(
        title: 'New session',
        subtitle: 'Start a fresh conversation',
        icon: Icons.add_circle_outline,
        onSelect: () async {
          final session = await ref
              .read(sessionsProvider.notifier)
              .createSession();
          ref.read(chatProvider.notifier).loadSession(session);
          if (mounted) Navigator.pop(context);
        },
      ),
      _PaletteEntry(
        title: 'Open settings',
        subtitle: 'API key, model, system prompt',
        icon: Icons.settings_outlined,
        onSelect: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      _PaletteEntry(
        title: 'Retry last message',
        subtitle: 'Re-run the most recent prompt',
        icon: Icons.refresh,
        onSelect: () {
          ref.read(chatProvider.notifier).retryLastMessage();
          Navigator.pop(context);
        },
      ),
      _PaletteEntry(
        title: 'Clear active files',
        subtitle: 'Remove all attached files from context',
        icon: Icons.layers_clear_outlined,
        onSelect: () {
          final files = ref.read(activeFilesProvider);
          for (final f in List.of(files)) {
            ref.read(chatProvider.notifier).removeFile(f.id);
          }
          Navigator.pop(context);
        },
      ),
    ];
    for (final a in actions) {
      if (q.isEmpty || a.title.toLowerCase().contains(q)) entries.add(a);
    }

    // Sessions
    final sessions = ref.read(sessionsProvider);
    final matchingSessions = sessions.where(
      (s) => q.isEmpty || s.title.toLowerCase().contains(q),
    );
    for (final s in matchingSessions.take(8)) {
      entries.add(
        _PaletteEntry(
          title: s.title,
          subtitle: '${s.messageCount} messages · ${s.updatedAt.toRelative()}',
          icon: Icons.chat_bubble_outline,
          trailing: s.isPinned
              ? const Icon(Icons.push_pin, size: 13, color: AppTheme.accent)
              : null,
          onSelect: () {
            ref.read(chatProvider.notifier).loadSession(s);
            Navigator.pop(context);
          },
        ),
      );
    }

    // Snippets (slash commands)
    if (q.startsWith('/') || q.isEmpty) {
      final snippets = ref.read(snippetsProvider);
      final matching = snippets.where(
        (s) =>
            q.isEmpty ||
            (s.shortcut?.contains(q) ?? false) ||
            s.title.toLowerCase().contains(q),
      );
      for (final s in matching) {
        entries.add(
          _PaletteEntry(
            title: s.shortcut ?? s.title,
            subtitle: s.title,
            icon: Icons.bolt_outlined,
            onSelect: () {
              Navigator.pop(context);
              // Hand off to caller via a global key/provider isn't available here,
              // so we just send it straight away as a quick action.
              ref.read(chatProvider.notifier).sendMessage(s.content);
            },
          ),
        );
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries(_controller.text);
    final clampedIndex = entries.isEmpty
        ? 0
        : _highlightedIndex.clamp(0, entries.length - 1);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 110),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 560,
            constraints: const BoxConstraints(maxHeight: 420),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is! KeyDownEvent) return;
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  setState(
                    () => _highlightedIndex = (clampedIndex + 1).clamp(
                      0,
                      (entries.length - 1).clamp(0, 999),
                    ),
                  );
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  setState(
                    () => _highlightedIndex = (clampedIndex - 1).clamp(
                      0,
                      (entries.length - 1).clamp(0, 999),
                    ),
                  );
                } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                  if (entries.isNotEmpty) entries[clampedIndex].onSelect();
                } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 18,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'Search sessions, run a command, or type / for snippets…',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) =>
                                setState(() => _highlightedIndex = 0),
                          ),
                        ),
                        _KeyHint(label: 'esc'),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  Flexible(
                    child: entries.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No results',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: entries.length,
                            itemBuilder: (_, i) {
                              final entry = entries[i];
                              final isHighlighted = i == clampedIndex;
                              return _PaletteRow(
                                entry: entry,
                                isHighlighted: isHighlighted,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.entry, required this.isHighlighted});
  final _PaletteEntry entry;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isHighlighted
          ? AppTheme.accent.withOpacity(0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: entry.onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Icon(
                entry.icon,
                size: 16,
                color: isHighlighted ? AppTheme.accent : AppTheme.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      entry.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.trailing != null) entry.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  const _KeyHint({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
      ),
    );
  }
}
