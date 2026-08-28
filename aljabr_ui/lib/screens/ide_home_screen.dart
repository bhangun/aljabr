import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/activity_bar/activity_bar_widget.dart';
import '../widgets/sidebar/sidebar_widget.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../widgets/extension_region_host.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/app_status_bar.dart';
import '../features/chat/widgets/chat/chat_panel.dart';
import '../features/editor/widgets/editor_panel_shell.dart';

import '../features/backend_monitor/providers/backend_process_provider.dart';
import '../features/backend_monitor/screens/backend_onboarding_dialog.dart';
import '../features/backend_monitor/services/backend_installer_service.dart';

import 'package:flutter/services.dart';
import '../core/commands/command_palette_dialog.dart';
import '../providers/module_manager_provider.dart';

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}

/// Composes the complete extensible shell:
/// Top Toolbar | (Activity Bar | Sidebar | Main Workbench) | Status Bar
class IdeHomeScreen extends ConsumerStatefulWidget {
  const IdeHomeScreen({super.key});

  @override
  ConsumerState<IdeHomeScreen> createState() => _IdeHomeScreenState();
}

class _IdeHomeScreenState extends ConsumerState<IdeHomeScreen> {
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
      builder: (context) => CommandPaletteDialog(
        registry: ref.read(commandRegistryProvider),
      ),
    );
  }

  Future<void> _checkBackendAndOnboard() async {
    try {
      final info =
          await ref.read(backendInstallerServiceProvider).detectInstallation();
      if (!info.isFullyInstalled && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const BackendOnboardingDialog(),
        );
      } else {
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
            body: Column(
              children: [
                const AppToolbar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      if (isWide) {
                        return const Row(
                          children: [
                            ActivityBarWidget(),
                            SidebarWidget(),
                            VerticalDivider(width: 1),
                            Expanded(
                              child: ExtensionRegionHost(
                                region: UiRegion.mainWorkbench,
                              ),
                            ),
                          ],
                        );
                      }
                      return const _NarrowLayout();
                    },
                  ),
                ),
                const AppStatusBar(),
              ],
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
  int _tab = 1;

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
