import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

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
