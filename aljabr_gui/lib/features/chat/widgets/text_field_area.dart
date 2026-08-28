import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import 'input/input_action.dart';

class TextFieldArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isExpanded;
  final VoidCallback onSend;

  const TextFieldArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isExpanded,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    // Attach the key listener directly to the focus node to intercept before TextField handles it.
    focusNode.onKeyEvent ??= (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          return KeyEventResult.ignored; // Let TextField insert newline
        } else {
          onSend();
          return KeyEventResult
              .handled; // Prevent TextField from inserting newline
        }
      }
      return KeyEventResult.ignored;
    };

    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: 1,
      maxLines: isExpanded ? 6 : 4,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.none, // Desktop relies on key event
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
        height: 1.5,
      ),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.fromLTRB(14, 12, 14, 12),
        hintText: 'Ask anything, @ to mention, / for actions',
        hintStyle: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 14,
        ),
        suffixIcon: InputActions(),
      ),
    );
  }
}
