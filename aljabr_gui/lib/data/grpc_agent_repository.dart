import 'dart:convert';
import '../features/chat/models/chat_entry.dart';
import '../features/chat/models/tool_call.dart';
import '../features/chat/models/tool_call_kind.dart';
import '../src/generated/wayang.pb.dart' as grpc;
import '../utils/logger.dart';
import 'agent_repository.dart';
import 'grpc_client.dart';

class GrpcAgentRepository implements AgentRepository {
  @override
  Stream<ChatEntry> observeSession(String sessionId) async* {
    final req = grpc.ObserveSessionRequest(sessionId: sessionId);
    final stream = grpcClient.chatClient.observeSession(req);

    await for (final msg in stream) {
      final role = msg.role.toUpperCase();
      ChatEntryType type = ChatEntryType.agentText;
      if (role == 'USER') {
        type = ChatEntryType.userPrompt;
      } else if (role == 'SYSTEM') {
        type = ChatEntryType.stepEvent;
      } else if (role == 'TOOL' && msg.toolCalls.isNotEmpty) {
        type = ChatEntryType.toolCall;
      }

      ToolCall? toolCall;
      if (type == ChatEntryType.toolCall) {
        try {
          final decoded = jsonDecode(msg.toolCalls);
          toolCall = ToolCall(
            id: msg.id,
            kind: ToolCallKindX.fromString(decoded['kind'] ?? ''),
            summary: decoded['summary'] ?? 'Tool Execution',
            detailInput: decoded['input'],
            detailOutput: decoded['output'],
            status: ToolCallStatus.success,
            duration: Duration.zero,
          );
        } catch (e) {
          logInfo("Failed to decode tool_calls json: $e");
        }
      }

      yield ChatEntry(
        id: msg.id,
        type: type,
        text: msg.content,
        toolCall: toolCall,
        status: ChatEntryStatus.completed,
        timestamp: DateTime.timestamp(),
      );
    }
  }
}
