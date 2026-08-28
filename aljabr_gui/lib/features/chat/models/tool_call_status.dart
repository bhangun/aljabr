import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

enum ToolCallStatus {
  running,
  success,
  error,
  queued,
  pending,
  cancelled,
  suspended
}

extension ToolCallStatusX on ToolCallStatus {
  Color get color {
    switch (this) {
      case ToolCallStatus.queued:
        return AppTheme.textMuted;
      case ToolCallStatus.pending:
        return AppTheme.accentAmber;
      case ToolCallStatus.running:
        return AppTheme.accentBlue;
      case ToolCallStatus.success:
        return AppTheme.accentGreen;
      case ToolCallStatus.error:
        return const Color(0xFFE0554C);
      case ToolCallStatus.cancelled:
        return AppTheme.textMuted;
      case ToolCallStatus.suspended:
        return Colors.purple;
    }
  }

  String get label {
    switch (this) {
      case ToolCallStatus.queued:
        return 'Queued';
      case ToolCallStatus.pending:
        return 'Pending approval';
      case ToolCallStatus.running:
        return 'Running';
      case ToolCallStatus.success:
        return 'Completed';
      case ToolCallStatus.error:
        return 'Failed';
      case ToolCallStatus.cancelled:
        return 'Cancelled';
      case ToolCallStatus.suspended:
        return 'Suspended';
    }
  }
}
