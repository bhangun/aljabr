import 'package:flutter/material.dart';

/// Lifecycle of a single agent session/run, shown as a colored badge
/// in the sidebar and the chat header (mirrors Codex/Antigravity's
/// "running / needs input / done" indicators).
enum SessionStatus {
  created,
  queued,
  running,
  waitingForApproval,
  paused,
  completed,
  failed,
  cancelled,
  archived,
}

extension SessionStatusExt on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.created:
        return 'Created';
      case SessionStatus.queued:
        return 'Queued';
      case SessionStatus.running:
        return 'Running';
      case SessionStatus.waitingForApproval:
        return 'Waiting for Approval';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.failed:
        return 'Failed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.archived:
        return 'Archived';
    }
  }

  Color get color {
    switch (this) {
      case SessionStatus.created:
        return Colors.grey;
      case SessionStatus.queued:
        return Colors.orange;
      case SessionStatus.running:
        return Colors.blue;
      case SessionStatus.waitingForApproval:
        return Colors.purple;
      case SessionStatus.paused:
        return Colors.amber;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.failed:
        return Colors.red;
      case SessionStatus.cancelled:
        return Colors.grey;
      case SessionStatus.archived:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case SessionStatus.created:
        return Icons.fiber_new;
      case SessionStatus.queued:
        return Icons.pending;
      case SessionStatus.running:
        return Icons.play_circle;
      case SessionStatus.waitingForApproval:
        return Icons.pause_circle;
      case SessionStatus.paused:
        return Icons.pause;
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.failed:
        return Icons.error;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.archived:
        return Icons.archive;
    }
  }
}
