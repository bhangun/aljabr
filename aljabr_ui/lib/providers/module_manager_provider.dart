import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../core/license/license_service.dart';
import '../core/license/pro_plugin_host.dart';

final extensionRuntimeProvider = Provider<ExtensionRuntime>((ref) {
  return ExtensionRuntime();
});

final moduleManagerProvider = Provider<ModuleManager>((ref) {
  final runtime = ref.watch(extensionRuntimeProvider);
  return ModuleManager(runtime: runtime);
});

final pluginManagerProvider = Provider<PluginManager>((ref) {
  final runtime = ref.watch(extensionRuntimeProvider);
  return PluginManager(runtime: runtime);
});

final proPluginHostProvider = Provider<ProPluginHost>((ref) {
  final pluginManager = ref.watch(pluginManagerProvider);
  final licenseInfo = ref.watch(licenseProvider);
  final host = ProPluginHost(
    pluginManager: pluginManager,
  );
  // Synchronize with current edition
  host.syncPlugins(licenseInfo.edition);
  return host;
});

final commandRegistryProvider = Provider<CommandRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).commands;
});

final viewRegistryProvider = Provider<ViewRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).views;
});

final navigationRegistryProvider = Provider<NavigationRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).navigation;
});

final settingsRegistryProvider = Provider<SettingsRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).settings;
});

final toolbarRegistryProvider = Provider<ToolbarRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).toolbar;
});

final contextMenuRegistryProvider = Provider<ContextMenuRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).contextMenus;
});

final statusBarRegistryProvider = Provider<StatusBarRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).statusBar;
});

final capabilityRegistryProvider = Provider<CapabilityRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).capabilities;
});

final eventBusProvider = Provider<EventBus>((ref) {
  return ref.watch(extensionRuntimeProvider).events;
});

final serviceRegistryProvider = Provider<ServiceRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).services;
});

final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).tools;
});

final activityBarRegistryProvider = Provider<ActivityBarRegistry>((ref) {
  return ref.watch(extensionRuntimeProvider).activityBar;
});

final contextServiceProvider = Provider<ContextService>((ref) {
  return ref.watch(extensionRuntimeProvider).contextService;
});

final workbenchControllerProvider = Provider<WorkbenchController>((ref) {
  return ref.watch(extensionRuntimeProvider).workbench;
});

class WorkbenchLayoutNotifier extends Notifier<WorkbenchLayoutState> {
  @override
  WorkbenchLayoutState build() {
    final controller = ref.watch(workbenchControllerProvider);
    controller.onLayoutChanged.listen((state) {
      this.state = state;
    });
    return controller.layout;
  }
}

final workbenchLayoutProvider =
    NotifierProvider<WorkbenchLayoutNotifier, WorkbenchLayoutState>(
  () => WorkbenchLayoutNotifier(),
);
