/// Aljabr Plugin API - Public contracts and contribution models.
library aljabr_plugin_api;

export 'src/ui/ui_location.dart';

export 'src/extensions/contribution.dart';
export 'src/extensions/contribution_ordering.dart';
export 'src/extensions/placed_contribution.dart';

export 'src/context/context_key.dart';
export 'src/context/contribution_context.dart';
export 'src/context/context_snapshot.dart';
export 'src/context/context_builder.dart';
export 'src/context/context_contributor.dart';

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

export 'src/plugins/plugin_metadata.dart';
export 'src/plugins/plugin_context.dart';
export 'src/plugins/aljabr_plugin.dart';

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
export 'src/views/view_contribution.dart';
