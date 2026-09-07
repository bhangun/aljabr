import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';

class WorkbenchCommands {
  static void registerAll({
    required CommandRegistry commandRegistry,
    required WorkbenchControllerApi workbench,
    WorkspaceModeController? workspaceModeController,
  }) {
    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.splitRight',
        title: 'View: Split Editor Right',
        category: 'View',
        action: (context) {
          final activeView = workbench.layout.activeViewIn(ViewArea.main);
          if (activeView != null) {
            workbench.splitView(
              activeView,
              direction: SplitDirection.horizontal,
              placement: SplitPlacement.after,
            );
          }
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.splitLeft',
        title: 'View: Split Editor Left',
        category: 'View',
        action: (context) {
          final activeView = workbench.layout.activeViewIn(ViewArea.main);
          if (activeView != null) {
            workbench.splitView(
              activeView,
              direction: SplitDirection.horizontal,
              placement: SplitPlacement.before,
            );
          }
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.splitUp',
        title: 'View: Split Editor Up',
        category: 'View',
        action: (context) {
          final activeView = workbench.layout.activeViewIn(ViewArea.main);
          if (activeView != null) {
            workbench.splitView(
              activeView,
              direction: SplitDirection.vertical,
              placement: SplitPlacement.before,
            );
          }
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.splitDown',
        title: 'View: Split Editor Down',
        category: 'View',
        action: (context) {
          final activeView = workbench.layout.activeViewIn(ViewArea.main);
          if (activeView != null) {
            workbench.splitView(
              activeView,
              direction: SplitDirection.vertical,
              placement: SplitPlacement.after,
            );
          }
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.focusNextGroup',
        title: 'View: Focus Next Editor Group',
        category: 'View',
        action: (context) {
          workbench.focusNextGroup(area: ViewArea.main);
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.focusPreviousGroup',
        title: 'View: Focus Previous Editor Group',
        category: 'View',
        action: (context) {
          workbench.focusPreviousGroup(area: ViewArea.main);
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.toggleSidebar',
        title: 'View: Toggle Primary Side Bar',
        category: 'View',
        action: (context) {
          workbench.toggleSidebar();
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.toggleBottom',
        title: 'View: Toggle Panel (Bottom)',
        category: 'View',
        action: (context) {
          workbench.toggleBottom();
        },
      ),
    );

    commandRegistry.register(
      AppCommand(
        id: 'aljabr.workbench.toggleSecondary',
        title: 'View: Toggle Secondary Side Bar',
        category: 'View',
        action: (context) {
          workbench.toggleSecondary();
        },
      ),
    );

    if (workspaceModeController != null) {
      commandRegistry.register(
        AppCommand(
          id: 'aljabr.mode.vibe',
          title: 'View: Switch to Vibe Coding Mode',
          category: 'View',
          action: (context) {
            workspaceModeController.setMode(CoreWorkspaceModes.vibe);
          },
        ),
      );

      commandRegistry.register(
        AppCommand(
          id: 'aljabr.mode.ide',
          title: 'View: Switch to IDE Workspace Mode',
          category: 'View',
          action: (context) {
            workspaceModeController.setMode(CoreWorkspaceModes.ide);
          },
        ),
      );

      commandRegistry.register(
        AppCommand(
          id: 'aljabr.mode.zen',
          title: 'View: Switch to Zen Focus Mode',
          category: 'View',
          action: (context) {
            workspaceModeController.setMode(CoreWorkspaceModes.zen);
          },
        ),
      );

      commandRegistry.register(
        AppCommand(
          id: 'aljabr.mode.cycle',
          title: 'View: Cycle Workspace Layout Modes',
          category: 'View',
          action: (context) {
            workspaceModeController.cycleNextMode();
          },
        ),
      );
    }
  }
}
