import '../commands/command_registry.dart';
import '../views/view_registry.dart';
import '../navigation/navigation_registry.dart';
import '../settings/settings_registry.dart';
import '../context_menu/context_menu_registry.dart';
import '../toolbar/toolbar_registry.dart';
import '../status_bar/status_bar_registry.dart';
import 'contribution.dart';

class ExtensionRuntime {
  final CommandRegistry commands;
  final ViewRegistry views;
  final NavigationRegistry navigation;
  final SettingsRegistry settings;
  final ContextMenuRegistry contextMenus;
  final ToolbarRegistry toolbar;
  final StatusBarRegistry statusBar;

  ExtensionRuntime({
    CommandRegistry? commands,
    ViewRegistry? views,
    NavigationRegistry? navigation,
    SettingsRegistry? settings,
    ContextMenuRegistry? contextMenus,
    ToolbarRegistry? toolbar,
    StatusBarRegistry? statusBar,
  })  : commands = commands ?? CommandRegistry(),
        views = views ?? ViewRegistry(),
        navigation = navigation ?? NavigationRegistry(),
        settings = settings ?? SettingsRegistry(),
        contextMenus = contextMenus ?? ContextMenuRegistry(),
        toolbar = toolbar ?? ToolbarRegistry(),
        statusBar = statusBar ?? StatusBarRegistry();

  List<OwnerCleanup> get cleanupTargets => [
        commands,
        views,
        navigation,
        settings,
        contextMenus,
        toolbar,
        statusBar,
      ];
}
