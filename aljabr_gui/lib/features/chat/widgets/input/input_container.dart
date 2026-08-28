import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../editor/providers/file_path_provider.dart';
import '../../models/input_bar_control.dart';
import '../../../../theme/app_colors.dart';
import 'input_footer.dart';
import '../text_field_area.dart';

class InputContainer extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputBarController inputController;
  final VoidCallback onSend;
  final List<String> slashCommands;
  final int tokens;
  final double costUsd;
  final String model;
  final bool hasText;

  const InputContainer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.inputController,
    required this.onSend,
    required this.slashCommands,
    required this.tokens,
    required this.costUsd,
    required this.model,
    required this.hasText,
  });

  @override
  ConsumerState<InputContainer> createState() => InputContainerState();
}

class InputContainerState extends ConsumerState<InputContainer> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cursor = widget.controller.selection.baseOffset;

    if (cursor < 0 || cursor > text.length) {
      widget.inputController.clearSuggestions();
      return;
    }

    // Parse for @mentions and /commands
    int i = cursor - 1;
    while (i >= 0 && text[i] != ' ' && text[i] != '\n') {
      if (text[i] == '@' || text[i] == '/') break;
      i--;
    }

    if (i < 0 || (text[i] != '@' && text[i] != '/')) {
      widget.inputController.clearSuggestions();
      return;
    }

    if (text[i] == '/' && i != 0) {
      widget.inputController.clearSuggestions();
      return;
    }

    final trigger = text[i];
    final query = text.substring(i + 1, cursor).toLowerCase();
    final pool =
        trigger == '@' ? ref.read(filePathsProvider) : widget.slashCommands;
    final matches =
        pool.where((p) => p.toLowerCase().contains(query)).take(6).toList();

    widget.inputController.updateSuggestions(trigger, i, matches);
    setState(() {
      _isExpanded = text.contains('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          TextFieldArea(
            controller: widget.controller,
            focusNode: widget.focusNode,
            isExpanded: _isExpanded,
            onSend: widget.onSend,
          ),
          InputFooter(
            controller: widget.controller,
            onSend: widget.onSend,
            hasText: widget.hasText,
            tokens: widget.tokens,
            costUsd: widget.costUsd,
          ),
        ],
      ),
    );
  }
}
