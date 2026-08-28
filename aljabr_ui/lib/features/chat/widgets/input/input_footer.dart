import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../button/add_menu_button.dart';
import '../mode_selector.dart';
import '../send_button.dart';
import '../usage_chip.dart';

class InputFooter extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final int tokens;
  final double costUsd;
  final bool hasText;

  const InputFooter({
    super.key,
    required this.controller,
    required this.onSend,
    required this.tokens,
    required this.costUsd,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const AddMenuButton(),
                  const Gap(4),
                  const ModelSelector(),
                  const Gap(10),
                  UsageChip(tokens: tokens, costUsd: costUsd),
                ],
              ),
            ),
          ),
          const Gap(8),
          SendButton(
            hasText: hasText,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
