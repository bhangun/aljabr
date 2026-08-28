import 'dart:async';
import 'aljabr_module.dart';
import 'module_context.dart';
import '../commands/command_registry.dart';
import '../views/view_registry.dart';
import '../navigation/navigation_registry.dart';
import '../settings/settings_registry.dart';
import '../toolbar/toolbar_registry.dart';
import '../context_menu/context_menu_registry.dart';
import '../status_bar/status_bar_registry.dart';
import '../capabilities/capability_registry.dart';
import '../events/event_bus.dart';
import '../services/service_registry.dart';
import '../tools/tool_registry.dart';
import '../activity_bar/activity_bar_registry.dart';
import '../extensions/extension_runtime.dart';

class ModuleManager {
  final Map<String, AljabrModule> _activeModules = {};
  final ExtensionRuntime runtime;

  ModuleManager({ExtensionRuntime? runtime})
      : runtime = runtime ?? ExtensionRuntime();

  CommandRegistry get commands => runtime.commands;
  ViewRegistry get views => runtime.views;
  NavigationRegistry get navigation => runtime.navigation;
  SettingsRegistry get settings => runtime.settings;
  ToolbarRegistry get toolbar => runtime.toolbar;
  ContextMenuRegistry get contextMenus => runtime.contextMenus;
  StatusBarRegistry get statusBar => runtime.statusBar;
  CapabilityRegistry get capabilities => runtime.capabilities;
  EventBus get events => runtime.events;
  ServiceRegistry get services => runtime.services;
  ToolRegistry get tools => runtime.tools;
  ActivityBarRegistry get activityBar => runtime.activityBar;

  Future<void> activate(AljabrModule module) async {
    if (_activeModules.containsKey(module.id)) {
      return;
    }

    final context = ModuleContext(
      moduleId: module.id,
      runtime: runtime,
    );

    await module.activate(context);
    _activeModules[module.id] = module;
  }

  Future<void> deactivate(String moduleId) async {
    final module = _activeModules[moduleId];
    if (module == null) return;

    await module.deactivate();

    for (final target in runtime.cleanupTargets) {
      target.unregisterAllForOwner(moduleId);
    }

    _activeModules.remove(moduleId);
  }

  List<AljabrModule> get activeModules => _activeModules.values.toList();
}
