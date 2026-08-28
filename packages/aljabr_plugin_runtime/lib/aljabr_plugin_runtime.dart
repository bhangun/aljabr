/// Aljabr Plugin Runtime - Host registries, layout engine, and lifecycle management.
library aljabr_plugin_runtime;

export 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

export 'src/extensions/contribution_registry.dart';
export 'src/extensions/placed_contribution_registry.dart';
export 'src/extensions/contribution_scope.dart';
export 'src/extensions/extension_runtime.dart';

export 'src/activity_bar/activity_bar_registry.dart';
export 'src/capabilities/capability.dart';
export 'src/capabilities/capability_registry.dart';
export 'src/commands/command_registry.dart';

export 'src/context/context_contributor_registry.dart';
export 'src/context/context_service.dart';

export 'src/context_menu/context_menu_registry.dart';
export 'src/navigation/navigation_registry.dart';

export 'src/plugins/runtime_plugin_context.dart';
export 'src/plugins/plugin_manager.dart';
export 'src/plugins/extension_manifest.dart';
export 'src/plugins/plugin_loader.dart';

export 'src/services/service_registry.dart';
export 'src/settings/settings_registry.dart';
export 'src/status_bar/status_bar_registry.dart';
export 'src/toolbar/toolbar_registry.dart';
export 'src/tools/tool_registry.dart';
export 'src/views/view_registry.dart';

export 'src/workbench/view_location.dart';
export 'src/workbench/workbench_layout_state.dart';
export 'src/workbench/workbench_layout_resolver.dart';
export 'src/workbench/workbench_controller.dart';
export 'src/workbench/plugin_cleanup_phase.dart';
export 'src/workbench/contribution_validator.dart';
