import '../extensions/contribution_registry.dart';
import 'agent_tool.dart';

class ToolRegistry extends ContributionRegistry<AgentTool> {
  Future<ToolResult> execute(ToolRequest request) async {
    final tool = get(request.toolId);
    if (tool == null) {
      return ToolResult.failure('Tool not found: ${request.toolId}');
    }
    try {
      return await tool.execute(request);
    } catch (e) {
      return ToolResult.failure('Tool execution failed: $e');
    }
  }
}
