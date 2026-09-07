import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'package:aljabr_plugin_chat/aljabr_plugin_chat.dart';
import 'package:aljabr_plugin_editor/aljabr_plugin_editor.dart';
import 'workbench_splitter.dart';

class VibeCodingWorkspaceView extends ConsumerStatefulWidget {
  const VibeCodingWorkspaceView({super.key});

  @override
  ConsumerState<VibeCodingWorkspaceView> createState() =>
      _VibeCodingWorkspaceViewState();
}

class _VibeCodingWorkspaceViewState
    extends ConsumerState<VibeCodingWorkspaceView> {
  bool _showInspector = true;
  double _chatFlex = 5.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          // Vibe Header Bar with quick prompt suggestion chips
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppTheme.panelAlt,
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 15, color: AppTheme.accent),
                const SizedBox(width: 8),
                const Text(
                  'VIBE AGENT STREAM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _VibeActionChip(label: '/plan', tooltip: 'Generate step-by-step implementation plan'),
                        SizedBox(width: 6),
                        _VibeActionChip(label: '/test', tooltip: 'Run test suite and verify changes'),
                        SizedBox(width: 6),
                        _VibeActionChip(label: '/diff', tooltip: 'Inspect pending code diffs'),
                        SizedBox(width: 6),
                        _VibeActionChip(label: '/refactor', tooltip: 'Propose architectural refactorings'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Tooltip(
                  message: _showInspector ? 'Hide Artifact & Diff Inspector' : 'Show Artifact & Diff Inspector',
                  child: InkWell(
                    onTap: () => setState(() => _showInspector = !_showInspector),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            _showInspector ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                            size: 15,
                            color: _showInspector ? AppTheme.accent : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showInspector ? 'Hide Inspector' : 'Show Inspector',
                            style: TextStyle(
                              fontSize: 11,
                              color: _showInspector ? AppTheme.accent : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Split Area: Conversational Agent Stream | Live Inspector
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: _chatFlex.round(),
                  child: const ChatPanel(slashCommands: []),
                ),
                if (_showInspector) ...[
                  WorkbenchSplitter(
                    axis: SplitterAxis.horizontal,
                    onDrag: (delta) {
                      setState(() {
                        _chatFlex = (_chatFlex + (delta > 0 ? 0.2 : -0.2)).clamp(2.0, 8.0);
                      });
                    },
                  ),
                  const Expanded(
                    flex: 4,
                    child: EditorPanelShell(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VibeActionChip extends StatelessWidget {
  final String label;
  final String tooltip;

  const _VibeActionChip({
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.accent,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
