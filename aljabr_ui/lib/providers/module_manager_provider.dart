import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';

final moduleManagerProvider = Provider<ModuleManager>((ref) {
  return ModuleManager();
});

final commandRegistryProvider = Provider<CommandRegistry>((ref) {
  return ref.watch(moduleManagerProvider).commands;
});

final viewRegistryProvider = Provider<ViewRegistry>((ref) {
  return ref.watch(moduleManagerProvider).views;
});

final navigationRegistryProvider = Provider<NavigationRegistry>((ref) {
  return ref.watch(moduleManagerProvider).navigation;
});

final settingsRegistryProvider = Provider<SettingsRegistry>((ref) {
  return ref.watch(moduleManagerProvider).settings;
});

final toolbarRegistryProvider = Provider<ToolbarRegistry>((ref) {
  return ref.watch(moduleManagerProvider).toolbar;
});

final contextMenuRegistryProvider = Provider<ContextMenuRegistry>((ref) {
  return ref.watch(moduleManagerProvider).contextMenus;
});

final statusBarRegistryProvider = Provider<StatusBarRegistry>((ref) {
  return ref.watch(moduleManagerProvider).statusBar;
});
