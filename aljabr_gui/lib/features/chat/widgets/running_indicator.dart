import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class RunningIndicator extends StatelessWidget {
  const RunningIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(
        strokeWidth: 1.8,
        color: AppTheme.accentBlue,
      ),
    );
  }
}
