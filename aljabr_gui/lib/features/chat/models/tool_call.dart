import 'risk_level.dart';
import 'tool_call_kind.dart';

/// One row in the transcript representing a tool the agent invoked — read a
/// file, ran a shell command, edited a file, etc. Expands to show the raw
/// input/output, the way Codex/Antigravity let you inspect each step.
class ToolCall {
  final String id;
  final ToolCallKind kind;
  final String summary;
  final String? detailInput;
  final String? detailOutput;
  final ToolCallStatus status;
  final RiskLevel risk;
  final Duration? duration;
  final String? errorMessage;
  final List<String>? subtasks; // For batch operations
  final Map<String, dynamic>? result;
  final int? progress; // 0-100 for long-running operations
  final bool isBlocking; // If true, session pauses until complete

  const ToolCall({
    required this.id,
    required this.kind,
    required this.summary,
    this.detailInput,
    this.detailOutput,
    this.status = ToolCallStatus.success,
    this.risk = RiskLevel.safe,
    this.duration,
    this.errorMessage,
    this.subtasks,
    this.result,
    this.progress,
    this.isBlocking = false,
  });

  ToolCall copyWith({
    String? id,
    ToolCallKind? kind,
    String? summary,
    String? detailInput,
    String? detailOutput,
    ToolCallStatus? status,
    RiskLevel? risk,
    Duration? duration,
    String? errorMessage,
    List<String>? subtasks,
    Map<String, dynamic>? result,
    int? progress,
    bool? isBlocking,
  }) {
    return ToolCall(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      summary: summary ?? this.summary,
      detailInput: detailInput ?? this.detailInput,
      detailOutput: detailOutput ?? this.detailOutput,
      status: status ?? this.status,
      risk: risk ?? this.risk,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      subtasks: subtasks ?? this.subtasks,
      result: result ?? this.result,
      progress: progress ?? this.progress,
      isBlocking: isBlocking ?? this.isBlocking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.toString(),
      'summary': summary,
      'detailInput': detailInput,
      'detailOutput': detailOutput,
      'status': status.toString(),
      'risk': risk.toString(),
      'duration': duration?.inMilliseconds,
      'errorMessage': errorMessage,
      'subtasks': subtasks,
      'result': result,
      'progress': progress,
      'isBlocking': isBlocking,
    };
  }

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'],
      kind: ToolCallKindX.fromString(json['kind'] ?? ''),
      summary: json['summary'],
      detailInput: json['detailInput'],
      detailOutput: json['detailOutput'],
      status: ToolCallStatus.values
          .firstWhere((e) => e.toString() == json['status']),
      risk: RiskLevel.values.firstWhere((e) => e.toString() == json['risk']),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      errorMessage: json['errorMessage'],
      subtasks: json['subtasks']?.cast<String>(),
      result: json['result'],
      progress: json['progress'],
      isBlocking: json['isBlocking'] ?? false,
    );
  }
}
