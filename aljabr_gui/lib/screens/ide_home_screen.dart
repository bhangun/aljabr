import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar/sidebar_widget.dart';
import '../features/chat/widgets/chat/chat_panel.dart';
import '../features/editor/widgets/editor_panel_shell.dart';

import '../features/backend_monitor/providers/backend_process_provider.dart';
import '../features/backend_monitor/screens/backend_onboarding_dialog.dart';
import '../features/backend_monitor/services/backend_installer_service.dart';

import 'package:flutter/services.dart';
import '../core/commands/command_palette_dialog.dart';
import '../core/commands/command_registry.dart';

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}

/// Composes the three modular columns from the reference screenshot:
/// sidebar | chat panel | code editor panel. Falls back to a tabbed
/// layout on narrow (mobile) widths so the same widgets are reusable there.
class IdeHomeScreen extends ConsumerStatefulWidget {
  const IdeHomeScreen({super.key});

  @override
  ConsumerState<IdeHomeScreen> createState() => _IdeHomeScreenState();
}

class _IdeHomeScreenState extends ConsumerState<IdeHomeScreen> {
  final CommandRegistry _commandRegistry = CommandRegistry();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBackendAndOnboard();
    });
  }

  void _openCommandPalette() {
    showDialog(
      context: context,
      builder: (context) => CommandPaletteDialog(registry: _commandRegistry),
    );
  }

  Future<void> _checkBackendAndOnboard() async {
    try {
      final info = await ref.read(backendDetectionProvider.future);
      if (!mounted) return;

      if (!info.isFullyInstalled) {
        // Show setup wizard if backends are not fully installed
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const BackendOnboardingDialog(),
        );
      } else {
        // Automatically start backends in order (Gollek -> Aljabr)
        ref.read(backendProcessProvider.notifier).startAll();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyP):
            const _OpenCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
            const _OpenCommandPaletteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (intent) => _openCommandPalette(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return const Row(
                    children: [
                      SidebarWidget(),
                      VerticalDivider(width: 1),
                      Expanded(
                        flex: 5,
                        child: ChatPanel(
                          slashCommands: [],
                        ),
                      ),
                      VerticalDivider(width: 1),
                      Expanded(flex: 4, child: EditorPanelShell()),
                    ],
                  );
                }
                return const _NarrowLayout();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatefulWidget {
  const _NarrowLayout();

  @override
  State<_NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<_NarrowLayout> {
  int _tab = 1; // default to chat, like the reference screenshot

  @override
  Widget build(BuildContext context) {
    const pages = [
      SidebarWidget(),
      ChatPanel(
        slashCommands: [],
      ),
      EditorPanelShell(),
    ];
    return Column(
      children: [
        Expanded(child: pages[_tab]),
        NavigationBar(
          selectedIndex: _tab,
          backgroundColor: AppTheme.panel,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.menu), label: 'Chats'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.code), label: 'Editor'),
          ],
        ),
      ],
    );
  }
}
