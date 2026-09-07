library aljabr_coding_core;

export 'src/theme/app_colors.dart';
export 'src/theme/app_radii.dart';
export 'src/theme/app_spacing.dart';
export 'src/theme/app_typography.dart';
export 'src/widgets/status_badge.dart';
export 'src/utils/syntax_highlighter.dart';
export 'src/utils/language.dart';
export 'src/utils/logger.dart';

// Chat & Agent Models
export 'src/models/chat_entry.dart';
export 'src/models/agent_plan.dart';
export 'src/models/plan_step.dart';
export 'src/models/tool_call.dart';
export 'src/models/tool_call_kind.dart';
export 'src/models/tool_call_timing.dart';
export 'src/models/file_node.dart';
export 'src/models/file_diff.dart';
export 'src/models/checkpoint.dart';
export 'src/models/attachment.dart';

// Project Models
export 'src/models/project.dart';
export 'src/models/project_detail.dart';
export 'src/models/project_settings.dart';
export 'src/models/request_latency.dart';
export 'src/models/rule_item.dart';
export 'src/models/security.dart';
export 'src/models/session.dart';
export 'src/models/session_analytics.dart';
export 'src/models/session_metrics.dart';
export 'src/models/session_mode.dart';
export 'src/models/session_statusx.dart';
export 'src/models/skill_detail.dart';
export 'src/models/skill_item.dart';

export 'src/models/agent_settings.dart';
export 'src/models/approval_request.dart';
export 'src/models/input_bar_control.dart';
export 'src/models/risk_level.dart';
export 'src/models/running_task.dart';

// Providers
export 'src/providers/active_project_provider.dart';
export 'src/providers/active_session_provider.dart';
export 'src/providers/project_list_provider.dart';
export 'src/providers/project_providers.dart';
export 'src/providers/session_list_provider.dart';
export 'src/providers/project_detail_provider.dart';
export 'src/providers/project_settings_provider.dart';
export 'src/providers/session_providers.dart';
export 'src/providers/transcript_provider.dart';
export 'src/providers/agent_settings_provider.dart';
export 'src/providers/editor_visible_provider.dart';
export 'src/providers/file_paths_provider.dart';
export 'src/providers/active_file_provider.dart';
export 'src/providers/backend_status_provider.dart';

// Backend Services
export 'src/data/backend_providers.dart';
export 'src/data/backend_service.dart';
export 'src/data/agent_repository.dart';
export 'src/data/sample_buffers.dart';
export 'src/services/session_monitor.dart';
