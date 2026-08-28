import '../commands/app_command.dart';
import '../commands/command_registry.dart';
import '../views/view_contribution.dart';
import '../views/view_registry.dart';
import '../navigation/navigation_contribution.dart';
import '../navigation/navigation_registry.dart';
import '../settings/settings_contribution.dart';
import '../settings/settings_registry.dart';
import '../context_menu/context_menu_contribution.dart';
import '../context_menu/context_menu_registry.dart';
import '../toolbar/toolbar_contribution.dart';
import '../toolbar/toolbar_registry.dart';
import '../status_bar/status_bar_contribution.dart';
import '../status_bar/status_bar_registry.dart';
import '../capabilities/capability.dart';
import '../capabilities/capability_registry.dart';
import '../events/event_bus.dart';
import '../services/service_registry.dart';
import '../tools/agent_tool.dart';
import '../tools/tool_registry.dart';
import '../activity_bar/activity_bar_contribution.dart';
import '../activity_bar/activity_bar_registry.dart';
import '../extensions/contribution_scope.dart';
import '../extensions/extension_runtime.dart';

class ModuleContext {
  final String moduleId;
  final ExtensionRuntime runtime;

  late final ContributionScope contributions =
      ContributionScope(ownerId: moduleId);

  ModuleContext({
    required this.moduleId,
    required this.runtime,
  });

  CommandRegistry get commands => runtime.commands;
  ViewRegistry get views => runtime.views;
  NavigationRegistry get navigation => runtime.navigation;
  SettingsRegistry get settings => runtime.settings;
  ContextMenuRegistry get contextMenus => runtime.contextMenus;
  ToolbarRegistry get toolbar => runtime.toolbar;
  StatusBarRegistry get statusBar => runtime.statusBar;
  CapabilityRegistry get capabilities => runtime.capabilities;
  EventBus get events => runtime.events;
  ServiceRegistry get services => runtime.services;
  ToolRegistry get tools => runtime.tools;
  ActivityBarRegistry get activityBar => runtime.activityBar;

  void registerCommand(AppCommand command) {
    commands.register(command, ownerId: moduleId);
  }

  void registerView(ViewContribution view) {
    contributions.register(views, view);
  }

  void registerNavigation(NavigationContribution item) {
    contributions.register(navigation, item);
  }

  void registerSettingsPage(SettingsPageContribution page) {
    contributions.register(settings, page);
  }

  void registerContextMenuItem(MenuContribution item) {
    contributions.register(contextMenus, item);
  }

  void registerToolbarItem(ToolbarContribution item) {
    contributions.register(toolbar, item);
  }

  void registerStatusBarItem(StatusBarContribution item) {
    contributions.register(statusBar, item);
  }

  void registerCapability(String capabilityId, {String description = ''}) {
    contributions.register(
      capabilities,
      CapabilityContribution(
        id: capabilityId,
        ownerId: moduleId,
        description: description,
      ),
    );
  }

  void registerService<T>(T service) {
    services.register<T>(service, ownerId: moduleId);
  }

  void registerTool(AgentTool tool) {
    contributions.register(tools, tool);
  }

  void registerActivityBarItem(ActivityBarContribution item) {
    contributions.register(activityBar, item);
  }
}
