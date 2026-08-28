import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../commands/command_registry.dart';
import '../views/view_registry.dart';
import '../navigation/navigation_registry.dart';
import '../settings/settings_registry.dart';
import '../context_menu/context_menu_registry.dart';
import '../toolbar/toolbar_registry.dart';
import '../status_bar/status_bar_registry.dart';
import '../capabilities/capability_registry.dart';
import '../services/service_registry.dart';
import '../tools/tool_registry.dart';
import '../activity_bar/activity_bar_registry.dart';
import '../context/context_contributor_registry.dart';
import '../context/context_service.dart';
import '../workbench/contribution_validator.dart';
import '../workbench/workbench_controller.dart';

class ExtensionRuntime {
  final CommandRegistry commands;
  final ViewRegistry views;
  final NavigationRegistry navigation;
  final SettingsRegistry settings;
  final ContextMenuRegistry contextMenus;
  final ToolbarRegistry toolbar;
  final StatusBarRegistry statusBar;
  final CapabilityRegistry capabilities;
  final EventBus events;
  final ServiceRegistry services;
  final ToolRegistry tools;
  final ActivityBarRegistry activityBar;
  final ContextContributorRegistry context;
  late final ContextService contextService;
  late final ContributionValidator validator;
  late final WorkbenchController workbench;

  ExtensionRuntime({
    CommandRegistry? commands,
    ViewRegistry? views,
    NavigationRegistry? navigation,
    SettingsRegistry? settings,
    ContextMenuRegistry? contextMenus,
    ToolbarRegistry? toolbar,
    StatusBarRegistry? statusBar,
    CapabilityRegistry? capabilities,
    EventBus? events,
    ServiceRegistry? services,
    ToolRegistry? tools,
    ActivityBarRegistry? activityBar,
    ContextContributorRegistry? context,
    WorkbenchController? workbench,
  })  : commands = commands ?? CommandRegistry(),
        views = views ?? ViewRegistry(),
        navigation = navigation ?? NavigationRegistry(),
        settings = settings ?? SettingsRegistry(),
        contextMenus = contextMenus ?? ContextMenuRegistry(),
        toolbar = toolbar ?? ToolbarRegistry(),
        statusBar = statusBar ?? StatusBarRegistry(),
        capabilities = capabilities ?? CapabilityRegistry(),
        events = events ?? EventBus(),
        services = services ?? ServiceRegistry(),
        tools = tools ?? ToolRegistry(),
        activityBar = activityBar ?? ActivityBarRegistry(),
        context = context ?? ContextContributorRegistry() {
    contextService = ContextService(registry: this.context);
    validator = ContributionValidator(views: this.views, activityBar: this.activityBar);
    this.workbench = workbench ?? WorkbenchController(views: this.views);
  }

  List<OwnerCleanup> get cleanupTargets => [
        commands,
        views,
        navigation,
        settings,
        contextMenus,
        toolbar,
        statusBar,
        capabilities,
        services,
        tools,
        activityBar,
        context,
      ];
}
