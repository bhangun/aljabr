import 'package:flutter/foundation.dart';

class InputBarController {
  String? triggerChar;
  int triggerStart = -1;
  List<String> suggestions = [];
  final ValueNotifier<bool> hasSuggestions = ValueNotifier(false);

  void clearSuggestions() {
    triggerChar = null;
    triggerStart = -1;
    suggestions = [];
    hasSuggestions.value = false;
  }

  void updateSuggestions(String? char, int start, List<String> newSuggestions) {
    triggerChar = char;
    triggerStart = start;
    suggestions = newSuggestions;
    hasSuggestions.value = newSuggestions.isNotEmpty;
  }

  void applySuggestion(String value) {
    // This is handled by the parent widget
  }

  void dispose() {
    hasSuggestions.dispose();
  }
}
