import '../activity_bar/activity_bar_contribution.dart';
import '../commands/app_command.dart';
import '../context/context_contributor.dart';
import '../context_menu/context_menu_contribution.dart';
import '../navigation/navigation_contribution.dart';
import '../settings/settings_contribution.dart';
import '../status_bar/status_bar_contribution.dart';
import '../toolbar/toolbar_contribution.dart';
import '../views/view_contribution.dart';

/// Interface for registering commands.
abstract interface class CommandRegistrar {
  /// Registers a command.
  void register(AppCommand command);
}

/// Interface for registering views.
abstract interface class ViewRegistrar {
  void register(ViewContribution view);
}

/// Interface for registering activity bar items.
abstract interface class ActivityBarRegistrar {
  void register(ActivityBarContribution item);
}

/// Interface for registering toolbar items.
abstract interface class ToolbarRegistrar {
  void register(ToolbarContribution item);
}

/// Interface for registering status bar items.
abstract interface class StatusBarRegistrar {
  void register(StatusBarContribution item);
}

/// Interface for registering menu items.
abstract interface class MenuRegistrar {
  void register(MenuContribution item);
}

/// Interface for registering navigation items.
abstract interface class NavigationRegistrar {
  void register(NavigationContribution item);
}

/// Interface for registering settings pages.
abstract interface class SettingsRegistrar {
  void register(SettingsPageContribution page);
}

/// Interface for registering context contributors.
abstract interface class ContextRegistrar {
  void register(ContextContribution contributor);
}

/// Interface for plugin UI API.
abstract interface class PluginUiApi {
  /// View registrar.
  ViewRegistrar get views;
  /// Activity bar registrar.
  ActivityBarRegistrar get activityBar;
  /// Toolbar registrar.
  ToolbarRegistrar get toolbar;
  /// Status bar registrar.
  StatusBarRegistrar get statusBar;
  /// Menu registrar.
  MenuRegistrar get menus;
  /// Navigation registrar.
  NavigationRegistrar get navigation;
  /// Settings registrar.
  SettingsRegistrar get settings;
}

/// Interface for capability service.
abstract interface class CapabilityService {
  /// Checks if the service supports the given capability ID.
  bool supports(String capabilityId);
}

/// Interface for plugin context.
abstract interface class PluginContext {
  /// The ID of the plugin.
  String get pluginId;
  /// The plugin UI API.
  PluginUiApi get ui;
  /// The command registrar.
  CommandRegistrar get commands;
  /// The context registrar.
  ContextRegistrar get context;
  CapabilityService get capabilities;
}
