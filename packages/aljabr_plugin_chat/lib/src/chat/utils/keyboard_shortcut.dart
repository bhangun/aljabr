import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts {
  static Map<LogicalKeySet, String> shortcuts = {
    // Navigation
    LogicalKeySet(LogicalKeyboardKey.arrowUp): 'navigate_up',
    LogicalKeySet(LogicalKeyboardKey.arrowDown): 'navigate_down',
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): 'navigate_left',
    LogicalKeySet(LogicalKeyboardKey.arrowRight): 'navigate_right',

    // Chat
    LogicalKeySet(LogicalKeyboardKey.enter): 'send_message',
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter):
        'new_line',
    LogicalKeySet(LogicalKeyboardKey.escape): 'cancel_input',

    // Actions
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
        'save_session',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ): 'undo',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY): 'redo',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
        'search',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
        'export_session',

    // Session control
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
        'pause_session',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
        'resume_session',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
        'cancel_current',

    // View
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.equal):
        'zoom_in',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.minus):
        'zoom_out',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit0):
        'reset_zoom',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
        'toggle_sidebar',
  };

  static String? getAction(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keySet = LogicalKeySet(event.logicalKey);
      return shortcuts[keySet];
    }
    return null;
  }
}
