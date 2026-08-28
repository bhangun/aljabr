import 'dart:async';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'aljabr_module.dart';
import 'module_context.dart';

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
  ContextContributorRegistry get contextContributors => runtime.context;
  ContextService get contextService => runtime.contextService;
  ContributionValidator get validator => runtime.validator;
  WorkbenchController get workbench => runtime.workbench;

  Future<void> activate(AljabrModule module) async {
    if (_activeModules.containsKey(module.id)) {
      return;
    }

    final context = ModuleContext(
      moduleId: module.id,
      runtime: runtime,
    );

    try {
      await module.activate(context);
      validator.validateOwner(module.id);
      _activeModules[module.id] = module;
    } catch (_) {
      for (final target in runtime.cleanupTargets) {
        target.unregisterAllForOwner(module.id);
      }
      rethrow;
    }
  }

  Future<void> deactivate(String moduleId) async {
    final module = _activeModules[moduleId];
    if (module == null) return;

    // Phase 1: Close workbench views owned by this module
    workbench.removeViewsOwnedBy(moduleId);

    // Phase 2: Module deactivation logic
    await module.deactivate();

    // Phase 3: Cleanup all contributed items from registries
    for (final target in runtime.cleanupTargets) {
      target.unregisterAllForOwner(moduleId);
    }

    _activeModules.remove(moduleId);
  }

  List<AljabrModule> get activeModules => _activeModules.values.toList();
}
