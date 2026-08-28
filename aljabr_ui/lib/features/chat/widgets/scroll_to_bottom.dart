import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onTap;
  const ScrollToBottomButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.panelAlt,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.arrow_downward,
            size: 18,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
