import 'risk_level.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'command': command,
      'reason': reason,
      'risk': risk.toString(),
      'status': status.toString(),
    };
  }

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'],
      command: json['command'],
      reason: json['reason'],
      risk: RiskLevel.values.firstWhere((e) => e.toString() == json['risk']),
      status: ApprovalStatus.values
          .firstWhere((e) => e.toString() == json['status']),
    );
  }
}
