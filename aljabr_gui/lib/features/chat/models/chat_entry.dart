import 'agent_plan.dart';
import 'attachment.dart';
import 'tool_call.dart';
import 'approval_request.dart';

/// The kind of row rendered in the chat transcript.
enum ChatEntryType {
  userPrompt,
  agentText,
  stepEvent,
  toolCall,
  approvalRequest,
  plan,
  attachment,
  systemMessage,
  thinking,
  search,
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
  final ChatEntryStatus status;
  final String text;
  final bool isLoading;
  final DateTime timestamp;
  final ToolCall? toolCall;
  final ApprovalRequest? approval;
  final AgentPlan? plan;
  final List<Attachment>? attachments;
  final String? errorMessage;
  final int? retryCount;
  final Map<String, dynamic>? metadata; // For flexible extension

  // Backend job/queue tracking
  final String? jobId;
  final int? queuePosition;

  const ChatEntry({
    required this.id,
    required this.type,
    required this.status,
    this.text = '',
    this.isLoading = false,
    required this.timestamp,
    this.toolCall,
    this.approval,
    this.plan,
    this.attachments,
    this.errorMessage,
    this.retryCount,
    this.metadata,
    this.jobId,
    this.queuePosition,
  });

  ChatEntry copyWith({
    String? id,
    ChatEntryType? type,
    ChatEntryStatus? status,
    String? text,
    bool? isLoading,
    DateTime? timestamp,
    ToolCall? toolCall,
    ApprovalRequest? approval,
    AgentPlan? plan,
    List<Attachment>? attachments,
    String? errorMessage,
    int? retryCount,
    Map<String, dynamic>? metadata,
    String? jobId,
    int? queuePosition,
  }) {
    return ChatEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      text: text ?? this.text,
      isLoading: isLoading ?? this.isLoading,
      timestamp: timestamp ?? this.timestamp,
      toolCall: toolCall ?? this.toolCall,
      approval: approval ?? this.approval,
      plan: plan ?? this.plan,
      attachments: attachments ?? this.attachments,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      metadata: metadata ?? this.metadata,
      jobId: jobId ?? this.jobId,
      queuePosition: queuePosition ?? this.queuePosition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'status': status.toString(),
      'text': text,
      'isLoading': isLoading,
      'timestamp': timestamp.toIso8601String(),
      'toolCall': toolCall?.toJson(),
      'approval': approval?.toJson(),
      'plan': plan?.toJson(),
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'errorMessage': errorMessage,
      'retryCount': retryCount,
      'metadata': metadata,
      'jobId': jobId,
      'queuePosition': queuePosition,
    };
  }

  factory ChatEntry.fromJson(Map<String, dynamic> json) {
    return ChatEntry(
      id: json['id'],
      type:
          ChatEntryType.values.firstWhere((e) => e.toString() == json['type']),
      status: ChatEntryStatus.values
          .firstWhere((e) => e.toString() == json['status']),
      text: json['text'] ?? '',
      isLoading: json['isLoading'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      toolCall:
          json['toolCall'] != null ? ToolCall.fromJson(json['toolCall']) : null,
      approval: json['approval'] != null
          ? ApprovalRequest.fromJson(json['approval'])
          : null,
      plan: json['plan'] != null ? AgentPlan.fromJson(json['plan']) : null,
      attachments: (json['attachments'] as List?)
          ?.map((a) => Attachment.fromJson(a))
          .toList(),
      errorMessage: json['errorMessage'],
      retryCount: json['retryCount'],
      metadata: json['metadata']?.cast<String, dynamic>(),
      jobId: json['jobId'],
      queuePosition: json['queuePosition'],
    );
  }
}

/// Status of a chat entry - extends beyond simple loading
enum ChatEntryStatus {
  pending, // Queued, waiting for backend capacity
  processing, // Being processed by agent
  suspended, // Paused waiting for approval/user input
  completed, // Successfully processed
  failed, // Failed with error
  cancelled, // Cancelled by user
}
