import 'package:flutter/material.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

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
