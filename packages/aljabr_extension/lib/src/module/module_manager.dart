import 'dart:async';
import 'aljabr_module.dart';
import 'module_context.dart';
import '../commands/app_command.dart';
import '../commands/command_registry.dart';
import '../views/view_contribution.dart';
import '../views/view_registry.dart';
import '../navigation/navigation_group.dart';
import '../navigation/navigation_contribution.dart';
import '../navigation/navigation_registry.dart';
import '../settings/settings_contribution.dart';
import '../settings/settings_registry.dart';
import '../toolbar/toolbar_contribution.dart';
import '../toolbar/toolbar_registry.dart';
import '../context_menu/context_menu_contribution.dart';
import '../context_menu/context_menu_registry.dart';
import '../status_bar/status_bar_contribution.dart';
import '../status_bar/status_bar_registry.dart';

class ModuleManager {
  final Map<String, AljabrModule> _activeModules = {};
  
  final CommandRegistry commands = CommandRegistry();
  final ViewRegistry views = ViewRegistry();
  final NavigationRegistry navigation = NavigationRegistry();
  final SettingsRegistry settings = SettingsRegistry();
  final ToolbarRegistry toolbar = ToolbarRegistry();
  final ContextMenuRegistry contextMenus = ContextMenuRegistry();
  final StatusBarRegistry statusBar = StatusBarRegistry();

  late final ModuleContext context;

  ModuleManager() {
    context = ModuleContext(
      commands: commands,
      views: views,
      navigation: navigation,
      settings: settings,
      toolbar: toolbar,
      contextMenus: contextMenus,
      statusBar: statusBar,
    );
  }

  Future<void> activate(AljabrModule module) async {
    if (_activeModules.containsKey(module.id)) {
      return;
    }
    
    final facade = _ModuleContextFacade(context, module.id);
    await module.activate(facade);
    
    _activeModules[module.id] = module;
  }

  Future<void> deactivate(String moduleId) async {
    final module = _activeModules[moduleId];
    if (module == null) return;

    await module.deactivate();

    commands.unregisterAllForOwner(moduleId);
    views.unregisterAllForOwner(moduleId);
    navigation.unregisterAllForOwner(moduleId);
    settings.unregisterAllForOwner(moduleId);
    toolbar.unregisterAllForOwner(moduleId);
    contextMenus.unregisterAllForOwner(moduleId);
    statusBar.unregisterAllForOwner(moduleId);

    _activeModules.remove(moduleId);
  }
}

class _ModuleContextFacade implements ModuleContext {
  final ModuleContext _delegate;
  final String _ownerId;

  _ModuleContextFacade(this._delegate, this._ownerId);

  @override
  CommandRegistry get commands => _CommandRegistryFacade(_delegate.commands, _ownerId);

  @override
  ViewRegistry get views => _ViewRegistryFacade(_delegate.views, _ownerId);

  @override
  NavigationRegistry get navigation => _NavigationRegistryFacade(_delegate.navigation, _ownerId);

  @override
  SettingsRegistry get settings => _SettingsRegistryFacade(_delegate.settings, _ownerId);

  @override
  ToolbarRegistry get toolbar => _ToolbarRegistryFacade(_delegate.toolbar, _ownerId);

  @override
  ContextMenuRegistry get contextMenus => _ContextMenuRegistryFacade(_delegate.contextMenus, _ownerId);

  @override
  StatusBarRegistry get statusBar => _StatusBarRegistryFacade(_delegate.statusBar, _ownerId);
}

class _CommandRegistryFacade implements CommandRegistry {
  final CommandRegistry _delegate;
  final String _ownerId;

  _CommandRegistryFacade(this._delegate, this._ownerId);

  @override
  void register(AppCommand command, {String? ownerId}) {
    _delegate.register(command, ownerId: _ownerId);
  }
  
  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);
  
  @override
  List<AppCommand> get all => _delegate.all;
  
  @override
  AppCommand? get(String id) => _delegate.get(id);

  @override
  List<AppCommand> search(String query) => _delegate.search(query);
}

class _ViewRegistryFacade implements ViewRegistry {
  final ViewRegistry _delegate;
  final String _ownerId;

  _ViewRegistryFacade(this._delegate, this._ownerId);

  @override
  void register(ViewContribution view, {String? ownerId}) {
    _delegate.register(view, ownerId: _ownerId);
  }
  
  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);
  
  @override
  List<ViewContribution> get all => _delegate.all;
  
  @override
  ViewContribution? get(String id) => _delegate.get(id);
}

class _NavigationRegistryFacade implements NavigationRegistry {
  final NavigationRegistry _delegate;
  final String _ownerId;

  _NavigationRegistryFacade(this._delegate, this._ownerId);

  @override
  void registerGroup(NavigationGroup group) {
    _delegate.registerGroup(group);
  }

  @override
  void register(NavigationContribution item, {String? ownerId}) {
    _delegate.register(item, ownerId: _ownerId);
  }
  
  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);
  
  @override
  List<NavigationGroup> get groups => _delegate.groups;
  
  @override
  List<NavigationContribution> itemsForGroup(String groupId) => _delegate.itemsForGroup(groupId);
}

class _SettingsRegistryFacade implements SettingsRegistry {
  final SettingsRegistry _delegate;
  final String _ownerId;

  _SettingsRegistryFacade(this._delegate, this._ownerId);

  @override
  void register(SettingsContribution contribution, {String? ownerId}) {
    _delegate.register(contribution, ownerId: _ownerId);
  }

  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);

  @override
  List<SettingsContribution> get all => _delegate.all;

  @override
  SettingsContribution? get(String id) => _delegate.get(id);
}

class _ToolbarRegistryFacade implements ToolbarRegistry {
  final ToolbarRegistry _delegate;
  final String _ownerId;

  _ToolbarRegistryFacade(this._delegate, this._ownerId);

  @override
  void register(ToolbarContribution item, {String? ownerId}) {
    _delegate.register(item, ownerId: _ownerId);
  }

  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);

  @override
  List<ToolbarContribution> get all => _delegate.all;

  @override
  ToolbarContribution? get(String id) => _delegate.get(id);
}

class _ContextMenuRegistryFacade implements ContextMenuRegistry {
  final ContextMenuRegistry _delegate;
  final String _ownerId;

  _ContextMenuRegistryFacade(this._delegate, this._ownerId);

  @override
  void register(ContextMenuContribution item, {String? ownerId}) {
    _delegate.register(item, ownerId: _ownerId);
  }

  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);

  @override
  List<ContextMenuContribution> itemsForLocation(String location) => _delegate.itemsForLocation(location);

  @override
  ContextMenuContribution? get(String id) => _delegate.get(id);
}

class _StatusBarRegistryFacade implements StatusBarRegistry {
  final StatusBarRegistry _delegate;
  final String _ownerId;

  _StatusBarRegistryFacade(this._delegate, this._ownerId);

  @override
  void register(StatusBarContribution item, {String? ownerId}) {
    _delegate.register(item, ownerId: _ownerId);
  }

  @override
  void unregisterAllForOwner(String ownerId) => _delegate.unregisterAllForOwner(ownerId);

  @override
  List<StatusBarContribution> get leftItems => _delegate.leftItems;

  @override
  List<StatusBarContribution> get rightItems => _delegate.rightItems;

  @override
  StatusBarContribution? get(String id) => _delegate.get(id);
}
