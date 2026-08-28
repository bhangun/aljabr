import '../features/chat/models/chat_entry.dart';
import '../features/chat/models/tool_call.dart';
import '../features/chat/models/tool_call_kind.dart';

/// Abstraction over however the app talks to the actual agent runtime.
/// A production build would implement this with a WebSocket or SSE client
/// that pushes tool-call/text events as the agent produces them; the mock
/// implementation below replays a short scripted sequence with realistic
/// delays so the UI has something to react to over time instead of a
/// frozen static transcript.
abstract class AgentRepository {
  /// Server-pushed follow-up events for [sessionId]. Each emission should
  /// be appended to that session's transcript as it arrives.
  Stream<ChatEntry> observeSession(String sessionId);
}

/// Mock implementation used throughout the app. Only session `wayang-code`
/// has a scripted continuation, so opening any other session is just quiet
/// (mirrors a real backend that has nothing further to say once a run has
/// actually finished).
class MockAgentRepository implements AgentRepository {
  @override
  Stream<ChatEntry> observeSession(String sessionId) {
    if (sessionId != 'wayang-code') return const Stream.empty();

    return Stream.fromFutures([
      Future.delayed(
        const Duration(seconds: 5),
        () => ChatEntry(
          id: 'live-tc1',
          type: ChatEntryType.toolCall,
          toolCall: const ToolCall(
            id: 'live-tc1',
            kind: ToolCallKind.runCommand,
            summary: './mvnw test -Dtest=SessionResourceTest',
            detailInput: './mvnw test -Dtest=SessionResourceTest',
            detailOutput:
                'Tests run: 6, Failures: 0, Errors: 0, Skipped: 0\nBUILD SUCCESS',
            status: ToolCallStatus.success,
            duration: Duration(seconds: 11),
          ),
          status: ChatEntryStatus.processing,
          timestamp: DateTime.timestamp(),
        ),
      ),
      Future.delayed(
        const Duration(seconds: 9),
        () => ChatEntry(
          id: 'live-e1',
          type: ChatEntryType.agentText,
          text:
              "All 6 tests pass with the updated Hibernate mapping. The `git push` above is still waiting on your approval before I merge — let me know if you'd like me to hold off instead.",
          status: ChatEntryStatus.suspended,
          timestamp: DateTime.timestamp(),
        ),
      ),
    ]);
  }
}
