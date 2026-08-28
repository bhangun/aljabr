import 'tool_call.dart';
import 'approval_request.dart';
import 'plan.dart';

/// The kind of row rendered in the chat transcript.
enum ChatEntryType {
  userPrompt,
  agentText,
  stepEvent,
  toolCall,
  approvalRequest,
  plan,
}

/// A single row in the chat transcript.
/// - [ChatEntryType.stepEvent] renders as a lightweight collapsible
///   "Worked for 16s" / "Timed 60 seconds" row (no structured data).
/// - [ChatEntryType.toolCall] renders as an expandable row backed by
///   [toolCall] (shows kind, status, and input/output on expand).
/// - [ChatEntryType.approvalRequest] renders as a blocking gate card
///   backed by [approval], with Approve/Deny actions.
/// - [ChatEntryType.plan] renders as a checklist backed by [plan], whose
///   step statuses update live as the agent makes progress.
/// - the other two render as normal chat bubbles.
class ChatEntry {
  final String id;
  final ChatEntryType type;
  final String text;
  final bool isLoading;
  final ToolCall? toolCall;
  final ApprovalRequest? approval;
  final AgentPlan? plan;

  const ChatEntry({
    required this.id,
    required this.type,
    this.text = '',
    this.isLoading = false,
    this.toolCall,
    this.approval,
    this.plan,
  });

  ChatEntry copyWith({ApprovalRequest? approval, ToolCall? toolCall, AgentPlan? plan}) {
    return ChatEntry(
      id: id,
      type: type,
      text: text,
      isLoading: isLoading,
      toolCall: toolCall ?? this.toolCall,
      approval: approval ?? this.approval,
      plan: plan ?? this.plan,
    );
  }
}
