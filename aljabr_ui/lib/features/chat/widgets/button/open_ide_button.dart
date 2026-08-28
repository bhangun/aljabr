import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class OpenIdeButton extends StatelessWidget {
  const OpenIdeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.bolt, size: 15, color: AppTheme.accentBlue),
      label: const Text(
        'Open IDE',
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.5),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
