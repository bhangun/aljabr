import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../models/problem_item.dart';
import '../providers/editor_panel_provider.dart';
import '../providers/open_file_provider.dart';
import '../providers/problem_provider.dart';

class ProblemsPanel extends ConsumerStatefulWidget {
  const ProblemsPanel({super.key});

  @override
  ConsumerState<ProblemsPanel> createState() => _ProblemsPanelState();
}

class _ProblemsPanelState extends ConsumerState<ProblemsPanel> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final problems = ref.watch(problemsProvider);
    final errorCount =
        problems.where((p) => p.severity == ProblemSeverity.error).length;
    final warnCount =
        problems.where((p) => p.severity == ProblemSeverity.warning).length;
    final infoCount =
        problems.where((p) => p.severity == ProblemSeverity.info).length;

    final filtered = _selectedCategory == 'ALL'
        ? problems
        : problems.where((p) => p.category == _selectedCategory).toList();

    return Container(
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Counter Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.panel,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SeveritySummaryBadge(
                    icon: Icons.error,
                    count: errorCount,
                    color: const Color(0xFFFF453A),
                    label: 'Errors',
                  ),
                  const SizedBox(width: 10),
                  _SeveritySummaryBadge(
                    icon: Icons.warning,
                    count: warnCount,
                    color: const Color(0xFFFF9F0A),
                    label: 'Warnings',
                  ),
                  const SizedBox(width: 10),
                  _SeveritySummaryBadge(
                    icon: Icons.info,
                    count: infoCount,
                    color: const Color(0xFF64D2FF),
                    label: 'Info',
                  ),
                  const SizedBox(width: 14),
                  // Filter chips
                  _CategoryFilterChip(
                    label: 'All',
                    selected: _selectedCategory == 'ALL',
                    onTap: () => setState(() => _selectedCategory = 'ALL'),
                  ),
                  const SizedBox(width: 4),
                  _CategoryFilterChip(
                    label: 'Security',
                    selected: _selectedCategory == 'SECURITY',
                    onTap: () => setState(() => _selectedCategory = 'SECURITY'),
                  ),
                  const SizedBox(width: 4),
                  _CategoryFilterChip(
                    label: 'Code Smell',
                    selected: _selectedCategory == 'CODE_SMELL',
                    onTap: () =>
                        setState(() => _selectedCategory = 'CODE_SMELL'),
                  ),
                ],
              ),
            ),
          ),

          // Problem List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No problems detected in workspace',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _ProblemRow(
                        item: item,
                        onTap: () {
                          // Open file and switch to Code tab
                          ref
                              .read(openFilesProvider.notifier)
                              .open(item.filePath);
                          ref
                              .read(activeFileProvider.notifier)
                              .select(item.filePath);
                          ref
                              .read(editorPanelTabProvider.notifier)
                              .select(EditorPanelTab.code);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  final ProblemItem item;
  final VoidCallback onTap;

  const _ProblemRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.severity) {
      ProblemSeverity.error => (Icons.error, const Color(0xFFFF453A)),
      ProblemSeverity.warning => (Icons.warning, const Color(0xFFFF9F0A)),
      ProblemSeverity.info => (Icons.info, const Color(0xFF64D2FF)),
    };

    return InkWell(
      onTap: onTap,
      hoverColor: AppTheme.sidebarSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.message,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.panelAlt,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          item.ruleId,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          item.filePath,
                          style: const TextStyle(
                            color: AppTheme.accentBlue,
                            fontSize: 11.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          ':${item.line}:${item.column}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeveritySummaryBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  const _SeveritySummaryBadge({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppTheme.sidebarSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppTheme.accentBlue : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
