import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// What kind of action a tool call represents — drives icon choice.
enum ToolCallKind { readFile, editFile, runCommand, search, webFetch }

extension ToolCallKindX on ToolCallKind {
  IconData get icon {
    switch (this) {
      case ToolCallKind.readFile:
        return Icons.description_outlined;
      case ToolCallKind.editFile:
        return Icons.edit_note;
      case ToolCallKind.runCommand:
        return Icons.terminal;
      case ToolCallKind.search:
        return Icons.search;
      case ToolCallKind.webFetch:
        return Icons.public;
    }
  }

  String get verb {
    switch (this) {
      case ToolCallKind.readFile:
        return 'Read file';
      case ToolCallKind.editFile:
        return 'Edit file';
      case ToolCallKind.runCommand:
        return 'Run command';
      case ToolCallKind.search:
        return 'Search';
      case ToolCallKind.webFetch:
        return 'Fetch URL';
    }
  }
}

enum ToolCallStatus { running, success, error }

extension ToolCallStatusX on ToolCallStatus {
  Color get color {
    switch (this) {
      case ToolCallStatus.running:
        return AppTheme.accentBlue;
      case ToolCallStatus.success:
        return AppTheme.accentGreen;
      case ToolCallStatus.error:
        return const Color(0xFFE0554C);
    }
  }
}

/// How risky an action is — used by the approval gate to decide styling
/// and whether the agent must pause for a human decision.
enum RiskLevel { safe, caution, dangerous }

extension RiskLevelX on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.safe:
        return AppTheme.accentGreen;
      case RiskLevel.caution:
        return AppTheme.accentAmber;
      case RiskLevel.dangerous:
        return const Color(0xFFE0554C);
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.safe:
        return 'Safe';
      case RiskLevel.caution:
        return 'Caution';
      case RiskLevel.dangerous:
        return 'Dangerous';
    }
  }
}

/// One row in the transcript representing a tool the agent invoked — read a
/// file, ran a shell command, edited a file, etc. Expands to show the raw
/// input/output, the way Codex/Antigravity let you inspect each step.
class ToolCall {
  final String id;
  final ToolCallKind kind;
  final String summary; // e.g. "mvn quarkus:dev -Dquarkus.http.port=8086"
  final String? detailInput;
  final String? detailOutput;
  final ToolCallStatus status;
  final RiskLevel risk;
  final Duration? duration;

  const ToolCall({
    required this.id,
    required this.kind,
    required this.summary,
    this.detailInput,
    this.detailOutput,
    this.status = ToolCallStatus.success,
    this.risk = RiskLevel.safe,
    this.duration,
  });
}
