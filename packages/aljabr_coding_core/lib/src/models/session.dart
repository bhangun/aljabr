import 'session_mode.dart';
import 'session_statusx.dart';

/// A single agent conversation/run scoped to a [Project]. This is what the
/// sidebar lists and what the chat panel + diff panel are keyed off of.
class Session {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final SessionStatus status;
  final SessionMode mode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;
  final String? forkOf;
  final bool isPinned;
  final int fileChanges;
  final int messageCount;
  final int pendingCount; // ← ADD THIS
  final int queueSize; // ← ADD THIS
  final Duration totalDuration;
  final Map<String, dynamic> metadata;
  final bool isSelected;

  const Session({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = SessionStatus.created,
    this.mode = SessionMode.hybrid,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.forkOf,
    this.isPinned = false,
    this.fileChanges = 0,
    this.messageCount = 0,
    this.pendingCount = 0, // ← ADD THIS
    this.queueSize = 0, // ← ADD THIS
    this.totalDuration = Duration.zero,
    this.metadata = const {},
    this.isSelected = false,
  });

  Session copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    SessionStatus? status,
    SessionMode? mode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    String? forkOf,
    bool? isPinned,
    int? fileChanges,
    int? messageCount,
    int? pendingCount, // ← ADD THIS
    int? queueSize, // ← ADD THIS
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
    bool? isSelected,
  }) {
    return Session(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      forkOf: forkOf ?? this.forkOf,
      isPinned: isPinned ?? this.isPinned,
      fileChanges: fileChanges ?? this.fileChanges,
      messageCount: messageCount ?? this.messageCount,
      pendingCount: pendingCount ?? this.pendingCount, // ← ADD THIS
      queueSize: queueSize ?? this.queueSize, // ← ADD THIS
      totalDuration: totalDuration ?? this.totalDuration,
      metadata: metadata ?? this.metadata,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'status': status.toString(),
        'mode': mode.toString(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'forkOf': forkOf,
        'isPinned': isPinned,
        'fileChanges': fileChanges,
        'messageCount': messageCount,
        'pendingCount': pendingCount, // ← ADD THIS
        'queueSize': queueSize, // ← ADD THIS
        'totalDuration': totalDuration.inMilliseconds,
        'metadata': metadata,
        'isSelected': isSelected,
      };

  factory Session.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'created';
    SessionStatus status;
    switch (statusStr) {
      case 'queued':
        status = SessionStatus.queued;
        break;
      case 'running':
        status = SessionStatus.running;
        break;
      case 'waitingForApproval':
        status = SessionStatus.waitingForApproval;
        break;
      case 'paused':
        status = SessionStatus.paused;
        break;
      case 'completed':
        status = SessionStatus.completed;
        break;
      case 'failed':
        status = SessionStatus.failed;
        break;
      case 'cancelled':
        status = SessionStatus.cancelled;
        break;
      case 'archived':
        status = SessionStatus.archived;
        break;
      default:
        status = SessionStatus.created;
    }

    final modeStr = json['mode'] as String? ?? 'hybrid';
    SessionMode mode;
    switch (modeStr) {
      case 'auto':
        mode = SessionMode.auto;
        break;
      case 'manual':
        mode = SessionMode.manual;
        break;
      case 'review':
        mode = SessionMode.review;
        break;
      default:
        mode = SessionMode.hybrid;
    }

    return Session(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: status,
      mode: mode,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      forkOf: json['forkOf'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      fileChanges: json['fileChanges'] as int? ?? 0,
      messageCount: json['messageCount'] as int? ?? 0,
      pendingCount: json['pendingCount'] as int? ?? 0, // ← ADD THIS
      queueSize: json['queueSize'] as int? ?? 0, // ← ADD THIS
      totalDuration: Duration(milliseconds: json['totalDuration'] as int? ?? 0),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final date = lastActiveAt ?? updatedAt;
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
