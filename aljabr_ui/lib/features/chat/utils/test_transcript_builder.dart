import '../models/chat_entry.dart';
import '../models/tool_call.dart';
import '../models/tool_call_kind.dart';

class TestTranscriptBuilder {
  final List<ChatEntry> entries = [];

  TestTranscriptBuilder addUserMessage(String text) {
    entries.add(ChatEntry(
      id: 'user-${entries.length}',
      type: ChatEntryType.userPrompt,
      status: ChatEntryStatus.completed,
      text: text,
      timestamp: DateTime.now(),
    ));
    return this;
  }

  TestTranscriptBuilder addAgentMessage(String text) {
    entries.add(ChatEntry(
      id: 'agent-${entries.length}',
      type: ChatEntryType.agentText,
      status: ChatEntryStatus.completed,
      text: text,
      timestamp: DateTime.now(),
    ));
    return this;
  }

  TestTranscriptBuilder addToolCall({
    required String summary,
    ToolCallKind kind = ToolCallKind.runCommand,
    ToolCallStatus status = ToolCallStatus.success,
  }) {
    entries.add(ChatEntry(
      id: 'tc-${entries.length}',
      type: ChatEntryType.toolCall,
      status: ChatEntryStatus.completed,
      timestamp: DateTime.now(),
      toolCall: ToolCall(
        id: 'tc-${entries.length}',
        kind: kind,
        summary: summary,
        status: status,
      ),
    ));
    return this;
  }

  TestTranscriptBuilder addPendingMessage(String text) {
    entries.add(ChatEntry(
      id: 'pending-${entries.length}',
      type: ChatEntryType.userPrompt,
      status: ChatEntryStatus.pending,
      text: text,
      timestamp: DateTime.now(),
    ));
    return this;
  }

  List<ChatEntry> build() => entries;
}
