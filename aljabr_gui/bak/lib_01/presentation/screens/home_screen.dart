import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/chat/states/chat_provider.dart';
import '../../features/chat/states/sessions_provider.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/message_list.dart';
import '../widgets/command_palette/command_palette.dart';
import '../widgets/diff/diff_viewer.dart';
import '../widgets/editor/editor_panel.dart';
import '../widgets/session/session_sidebar.dart';
import '../widgets/shared/api_key_banner.dart';
import '../widgets/shared/resizable_split_view.dart';
import '../widgets/shared/shared_widgets.dart';
import '../../features/settings/screens/settings_screen.dart';

enum PanelTab { editor, diff }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PanelTab _rightTab = PanelTab.editor;
  bool _sidebarVisible = true;

  static const _newSessionShortcut = SingleActivator(
    LogicalKeyboardKey.keyN,
    meta: true,
  );
  static const _newSessionShortcutCtrl = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: true,
  );
  static const _paletteShortcut = SingleActivator(
    LogicalKeyboardKey.keyK,
    meta: true,
  );
  static const _paletteShortcutCtrl = SingleActivator(
    LogicalKeyboardKey.keyK,
    control: true,
  );
  static const _toggleSidebarShortcut = SingleActivator(
    LogicalKeyboardKey.backslash,
    meta: true,
  );
  static const _toggleSidebarShortcutCtrl = SingleActivator(
    LogicalKeyboardKey.backslash,
    control: true,
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final session = ref.watch(activeSessionProvider);
    final selectedDiff = ref.watch(selectedDiffProvider);

    if (selectedDiff != null && _rightTab != PanelTab.diff) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _rightTab = PanelTab.diff);
      });
    }

    return CallbackShortcuts(
      bindings: {
        _newSessionShortcut: _createNewSession,
        _newSessionShortcutCtrl: _createNewSession,
        _paletteShortcut: () => showCommandPalette(context),
        _paletteShortcutCtrl: () => showCommandPalette(context),
        _toggleSidebarShortcut: () =>
            setState(() => _sidebarVisible = !_sidebarVisible),
        _toggleSidebarShortcutCtrl: () =>
            setState(() => _sidebarVisible = !_sidebarVisible),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: Row(
            children: [
              if (_sidebarVisible) ...[
                const SessionSidebar(),
                Container(width: 0.5, color: AppTheme.border),
              ],
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      title: session?.title ?? 'CodexAgent',
                      rightTab: _rightTab,
                      sidebarVisible: _sidebarVisible,
                      onTabChange: (t) => setState(() => _rightTab = t),
                      onToggleSidebar: () =>
                          setState(() => _sidebarVisible = !_sidebarVisible),
                      onSettings: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    Container(height: 0.5, color: AppTheme.border),
                    Expanded(
                      child: width > 900
                          ? _WideLayout(rightTab: _rightTab)
                          : const _NarrowLayout(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createNewSession() async {
    final session = await ref.read(sessionsProvider.notifier).createSession();
    ref.read(chatProvider.notifier).loadSession(session);
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.rightTab});
  final PanelTab rightTab;

  @override
  Widget build(BuildContext context) {
    return ResizableSplitView(
      left: const _ChatPanel(),
      right: switch (rightTab) {
        PanelTab.editor => const EditorPanel(),
        PanelTab.diff => const DiffPanel(),
      },
    );
  }
}

/// Narrow / mobile layout: chat fills the screen, editor and diff are
/// reached via bottom sheets so nothing is permanently hidden.
class _NarrowLayout extends ConsumerWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFiles = ref.watch(activeFilesProvider);
    final selectedDiff = ref.watch(selectedDiffProvider);

    return Stack(
      children: [
        const _ChatPanel(),
        if (activeFiles.isNotEmpty || selectedDiff != null)
          Positioned(
            right: 12,
            bottom: 88,
            child: Column(
              children: [
                if (activeFiles.isNotEmpty)
                  _FloatingPanelButton(
                    icon: Icons.code,
                    label: '${activeFiles.length}',
                    onTap: () =>
                        _openSheet(context, const EditorPanel(), 'Files'),
                  ),
                if (selectedDiff != null) ...[
                  const SizedBox(height: 8),
                  _FloatingPanelButton(
                    icon: Icons.difference,
                    label: 'Diff',
                    color: AppTheme.success,
                    onTap: () => _openSheet(context, const DiffPanel(), 'Diff'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  void _openSheet(BuildContext context, Widget child, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FloatingPanelButton extends StatelessWidget {
  const _FloatingPanelButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppTheme.accent,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ApiKeyBanner(),
        Expanded(child: MessageList()),
        ChatInputBar(),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({
    required this.title,
    required this.rightTab,
    required this.sidebarVisible,
    required this.onTabChange,
    required this.onToggleSidebar,
    required this.onSettings,
  });
  final String title;
  final PanelTab rightTab;
  final bool sidebarVisible;
  final ValueChanged<PanelTab> onTabChange;
  final VoidCallback onToggleSidebar;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      height: 44,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (width > 900)
            Tooltip(
              message: sidebarVisible
                  ? 'Hide sidebar (⌘\\)'
                  : 'Show sidebar (⌘\\)',
              child: IconButton(
                onPressed: onToggleSidebar,
                icon: Icon(
                  sidebarVisible
                      ? Icons.view_sidebar
                      : Icons.view_sidebar_outlined,
                  size: 17,
                ),
                color: AppTheme.textSecondary,
                splashRadius: 15,
              ),
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: PulsingDots(),
            ),
          Expanded(
            flex: 2,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          if (width > 900)
            _TabToggle<PanelTab>(
              tabs: const [
                (PanelTab.editor, Icons.code, 'Editor'),
                (PanelTab.diff, Icons.difference, 'Diff'),
              ],
              selected: rightTab,
              onSelect: onTabChange,
            ),
          const SizedBox(width: 10),
          if (session != null) const _RetryButton(),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, size: 18),
            color: AppTheme.textSecondary,
            tooltip: 'Settings',
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
}

class _RetryButton extends ConsumerWidget {
  const _RetryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    return IconButton(
      onPressed: isLoading
          ? null
          : () => ref.read(chatProvider.notifier).retryLastMessage(),
      icon: const Icon(Icons.refresh, size: 17),
      color: AppTheme.textMuted,
      tooltip: 'Retry last message',
      splashRadius: 15,
    );
  }
}

class _TabToggle<T> extends StatelessWidget {
  const _TabToggle({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });
  final List<(T, IconData, String)> tabs;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final (value, icon, label) = tab;
          final isSelected = value == selected;
          return GestureDetector(
            onTap: () => onSelect(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
