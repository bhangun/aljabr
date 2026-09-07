import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'package:aljabr_plugin_chat/aljabr_plugin_chat.dart';
import 'package:aljabr_plugin_editor/aljabr_plugin_editor.dart';
import 'package:aljabr_plugin_diff/aljabr_plugin_diff.dart';
import '../../../theme/app_colors.dart';

enum VsCodeSidebarTab {
  explorer,
  search,
  sourceControl,
  extensions,
  assistant,
}

class VsCodeSidebarTabNotifier extends Notifier<VsCodeSidebarTab> {
  @override
  VsCodeSidebarTab build() => VsCodeSidebarTab.explorer;

  void select(VsCodeSidebarTab tab) => state = tab;
}

final vsCodeSidebarTabProvider =
    NotifierProvider<VsCodeSidebarTabNotifier, VsCodeSidebarTab>(
  () => VsCodeSidebarTabNotifier(),
);

class VsCodeSidebarView extends ConsumerStatefulWidget {
  const VsCodeSidebarView({super.key});

  @override
  ConsumerState<VsCodeSidebarView> createState() => _VsCodeSidebarViewState();
}

class _VsCodeSidebarViewState extends ConsumerState<VsCodeSidebarView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commitController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _commitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(vsCodeSidebarTabProvider);

    return Container(
      width: 270,
      color: AppTheme.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: switch (activeTab) {
              VsCodeSidebarTab.explorer => const FileExplorerPanel(),
              VsCodeSidebarTab.search => _buildSearchPanel(),
              VsCodeSidebarTab.sourceControl => _buildSourceControlPanel(),
              VsCodeSidebarTab.extensions => _buildExtensionsPanel(),
              VsCodeSidebarTab.assistant => const ChatPanel(slashCommands: []),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Row(
            children: [
              Text(
                'SEARCH',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 15, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Search files (⌘F)',
                          hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  _SearchOptionToggle(label: 'Aa', tooltip: 'Match Case'),
                  SizedBox(width: 4),
                  _SearchOptionToggle(label: 'ab', tooltip: 'Match Whole Word'),
                  SizedBox(width: 4),
                  _SearchOptionToggle(label: '.*', tooltip: 'Use Regular Expression'),
                ],
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'No search results yet',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceControlPanel() {
    final sessionId = ref.watch(activeSessionIdProvider);
    final diffs = ref.watch(fileDiffsProvider(sessionId));
    final activeProject = ref.watch(activeProjectProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Text(
                'SOURCE CONTROL',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.call_split, size: 11, color: AppTheme.accent),
                    SizedBox(width: 4),
                    Text(
                      'main',
                      style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _commitController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Message (⌘Enter to commit)',
                    hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _commitController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Changes staged and committed.')),
                    );
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Commit & Push', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppTheme.panelAlt,
          child: Row(
            children: [
              const Icon(Icons.keyboard_arrow_down, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              const Text(
                'CHANGES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${diffs.length}',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: diffs.isEmpty
              ? Center(
                  child: Text(
                    activeProject == null ? 'No active repository' : 'No changes detected',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  itemCount: diffs.length,
                  itemBuilder: (context, index) {
                    final diff = diffs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 13, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              diff.path,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(
                            'M',
                            style: TextStyle(fontSize: 11, color: AppTheme.accentAmber, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExtensionsPanel() {
    final extensions = [
      ('Dart & Flutter Tooling', 'Rich language server, debugging, and widget inspector', 'Installed'),
      ('Aljabr Copilot Agent', 'Conversational AI agent for autonomous coding & refactor', 'Installed'),
      ('GitLens & History', 'Visual commit graph, blame annotations, and branch compare', 'Installed'),
      ('Sonar Quality Gate', 'Static analysis, security rule enforcement, and test coverage', 'Installed'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Row(
            children: [
              Text(
                'EXTENSIONS & MARKETPLACE',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: extensions.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
            itemBuilder: (context, index) {
              final ext = extensions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.extension_outlined, size: 18, color: AppTheme.accent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ext.$1,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ext.$2,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchOptionToggle extends StatefulWidget {
  final String label;
  final String tooltip;

  const _SearchOptionToggle({required this.label, required this.tooltip});

  @override
  State<_SearchOptionToggle> createState() => _SearchOptionToggleState();
}

class _SearchOptionToggleState extends State<_SearchOptionToggle> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        onTap: () => setState(() => _active = !_active),
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _active ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.surface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: _active ? AppTheme.accent : AppTheme.border,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: _active ? AppTheme.accent : AppTheme.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
