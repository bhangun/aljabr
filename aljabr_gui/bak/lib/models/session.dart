import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Lifecycle of a single agent session/run, shown as a colored badge
/// in the sidebar and the chat header (mirrors Codex/Antigravity's
/// "running / needs input / done" indicators).
enum SessionStatus { queued, running, waitingForApproval, completed, failed }

extension SessionStatusX on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.queued:
        return 'Queued';
      case SessionStatus.running:
        return 'Running';
      case SessionStatus.waitingForApproval:
        return 'Needs input';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case SessionStatus.queued:
        return AppTheme.textMuted;
      case SessionStatus.running:
        return AppTheme.accentBlue;
      case SessionStatus.waitingForApproval:
        return AppTheme.accentAmber;
      case SessionStatus.completed:
        return AppTheme.accentGreen;
      case SessionStatus.failed:
        return const Color(0xFFE0554C);
    }
  }

  IconData get icon {
    switch (this) {
      case SessionStatus.queued:
        return Icons.schedule;
      case SessionStatus.running:
        return Icons.autorenew;
      case SessionStatus.waitingForApproval:
        return Icons.pause_circle_outline;
      case SessionStatus.completed:
        return Icons.check_circle_outline;
      case SessionStatus.failed:
        return Icons.error_outline;
    }
  }
}

/// A single agent conversation/run scoped to a [Project]. This is what the
/// sidebar lists and what the chat panel + diff panel are keyed off of.
class Session {
  final String id;
  final String projectId;
  final String title;
  final String timeAgo;
  final SessionStatus status;
  final bool isPinned;
  final bool isSelected;
  final int filesChanged;

  const Session({
    required this.id,
    required this.projectId,
    required this.title,
    required this.timeAgo,
    required this.status,
    this.isPinned = false,
    this.isSelected = false,
    this.filesChanged = 0,
  });

  Session copyWith({bool? isSelected, SessionStatus? status}) {
    return Session(
      id: id,
      projectId: projectId,
      title: title,
      timeAgo: timeAgo,
      status: status ?? this.status,
      isPinned: isPinned,
      isSelected: isSelected ?? this.isSelected,
      filesChanged: filesChanged,
    );
  }
}
