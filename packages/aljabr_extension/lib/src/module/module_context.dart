import '../commands/command_registry.dart';
import '../views/view_registry.dart';
import '../navigation/navigation_registry.dart';
import '../settings/settings_registry.dart';
import '../toolbar/toolbar_registry.dart';
import '../context_menu/context_menu_registry.dart';
import '../status_bar/status_bar_registry.dart';

class ModuleContext {
  final CommandRegistry commands;
  final ViewRegistry views;
  final NavigationRegistry navigation;
  final SettingsRegistry settings;
  final ToolbarRegistry toolbar;
  final ContextMenuRegistry contextMenus;
  final StatusBarRegistry statusBar;

  const ModuleContext({
    required this.commands,
    required this.views,
    required this.navigation,
    required this.settings,
    required this.toolbar,
    required this.contextMenus,
    required this.statusBar,
  });
}
