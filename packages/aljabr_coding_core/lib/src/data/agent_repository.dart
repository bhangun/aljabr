import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_entry.dart';
import '../models/tool_call.dart';
import '../models/tool_call_kind.dart';

/// Abstraction over how the app communicates with the agent runtime.
abstract class AgentRepository {
  /// Stream of server-pushed follow-up events for [sessionId].
  Stream<ChatEntry> observeSession(String sessionId);
}

/// Mock implementation used throughout the app / tests.
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

/// Active [AgentRepository] provider.
final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return MockAgentRepository();
});
