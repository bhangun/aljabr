import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class InputActions extends StatelessWidget {
  const InputActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InputActionButton(
            icon: Icons.attach_file,
            onPressed: () {},
          ),
          const Gap(4),
          _InputActionButton(
            icon: Icons.mic_none,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _InputActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _InputActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: AppTheme.textMuted),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
