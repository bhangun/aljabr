import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/input_bar_control.dart';
import 'suggestion_list.dart';

class SuggestionsOverlay extends ConsumerWidget {
  final TextEditingController controller;
  final InputBarController inputController;
  final ValueChanged<String> onSelect;

  const SuggestionsOverlay({
    super.key,
    required this.controller,
    required this.inputController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: inputController.hasSuggestions,
      builder: (context, hasSuggestions, _) {
        if (!hasSuggestions || inputController.suggestions.isEmpty) {
          return const SizedBox.shrink();
        }
        return SuggestionsList(
          trigger: inputController.triggerChar!,
          suggestions: inputController.suggestions,
          onSelect: onSelect,
        );
      },
    );
  }
}
