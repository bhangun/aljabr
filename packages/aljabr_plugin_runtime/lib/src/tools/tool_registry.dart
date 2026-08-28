import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../extensions/contribution_registry.dart';

class ToolRegistry extends ContributionRegistry<AgentTool> {
  AgentTool? findByName(String name) => get(name);

  List<AgentTool> get availableTools => getAll();
}
