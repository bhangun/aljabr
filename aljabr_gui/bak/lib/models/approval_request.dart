import 'tool_call.dart';

enum ApprovalStatus { pending, approved, denied }

/// A blocking request the agent raises before doing something risky
/// (pushing, deleting, running an unreviewed script). The transcript
/// stops progressing new tool calls until this is resolved.
class ApprovalRequest {
  final String id;
  final String command;
  final String reason;
  final RiskLevel risk;
  final ApprovalStatus status;

  const ApprovalRequest({
    required this.id,
    required this.command,
    required this.reason,
    required this.risk,
    this.status = ApprovalStatus.pending,
  });

  ApprovalRequest copyWith({ApprovalStatus? status}) {
    return ApprovalRequest(
      id: id,
      command: command,
      reason: reason,
      risk: risk,
      status: status ?? this.status,
    );
  }
}
