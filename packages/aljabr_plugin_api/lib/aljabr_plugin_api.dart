/// Aljabr Plugin API - Public contracts and contribution models.
library aljabr_plugin_api;

export 'src/ui/ui_surface.dart';
export 'src/ui/ui_location.dart';
export 'src/ui/ui_contribution.dart';

export 'src/extensions/contribution.dart';
export 'src/extensions/contribution_ordering.dart';
export 'src/extensions/placed_contribution.dart';

export 'src/context/context_key.dart';
export 'src/context/contribution_context.dart';
export 'src/context/context_builder.dart';
export 'src/context/context_contributor.dart';
export 'src/context/reactive_context_contracts.dart';

export 'src/activity_bar/activity_bar_section.dart';
export 'src/activity_bar/activity_bar_contribution.dart';

export 'src/commands/app_command.dart';
export 'src/commands/command_context.dart';

export 'src/context_menu/menu_target.dart';
export 'src/context_menu/menu_context.dart';
export 'src/context_menu/context_menu_contribution.dart';

export 'src/events/core_events.dart';
export 'src/events/event_bus.dart';

export 'src/navigation/navigation_group.dart';
export 'src/navigation/navigation_contribution.dart';
export 'src/navigation/navigation_contracts.dart';

export 'src/plugins/plugin_metadata.dart';
export 'src/plugins/plugin_context.dart';
export 'src/plugins/aljabr_plugin.dart';
export 'src/plugins/plugin_sdk_contracts.dart';

export 'src/settings/settings_contribution.dart';

export 'src/status_bar/status_bar_alignment.dart';
export 'src/status_bar/status_bar_context.dart';
export 'src/status_bar/status_bar_contribution.dart';

export 'src/toolbar/toolbar_alignment.dart';
export 'src/toolbar/toolbar_context.dart';
export 'src/toolbar/toolbar_contribution.dart';

export 'src/tools/agent_tool.dart';

export 'src/views/ui_region.dart';
export 'src/views/view_area.dart';
export 'src/views/view_placement.dart';
export 'src/views/view_behavior.dart';
export 'src/views/view_descriptor.dart';
export 'src/views/view_availability.dart';
export 'src/views/persisted_view_reference.dart';
export 'src/views/view_contribution.dart';

export 'src/workbench/workspace_mode.dart';
export 'src/workbench/layout_repair.dart';

export 'src/shell/shell_region_contracts.dart';
export 'src/composition/composition_contracts.dart';
export 'src/runtime_scope/runtime_scope_contracts.dart';
export 'src/capabilities/capabilities_models.dart';
export 'src/reactivity/signals_contracts.dart';
export 'src/commands/command_interaction_contracts.dart';
export 'src/manifest/manifest_models.dart';
export 'src/capabilities/capability_broker_contracts.dart';
export 'src/ui_contributions/ui_contribution_contracts.dart';
export 'src/transaction/transaction_contracts.dart';
export 'src/layout/declarative_layout_contracts.dart';

// UI State Projection, Packaging, Discovery & Service Graph (UI 19-22)
export 'src/projection/projection_contracts.dart';
export 'src/packaging/packaging_contracts.dart';
export 'src/discovery/discovery_contracts.dart';
export 'src/di/service_graph_contracts.dart';

