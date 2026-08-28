import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/intent.dart';

class ShortcutsOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSendMessage;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onSearch;
  final VoidCallback? onExport;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onToggleSidebar;

  const ShortcutsOverlay({
    super.key,
    required this.child,
    this.onSendMessage,
    this.onUndo,
    this.onRedo,
    this.onSearch,
    this.onExport,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Navigation
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () => _navigate(-1),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () => _navigate(1),

        // Chat
        LogicalKeySet(LogicalKeyboardKey.enter): () => onSendMessage?.call(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter): () =>
            _newLine(),
        LogicalKeySet(LogicalKeyboardKey.escape): () => _cancelInput(),

        // Actions
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            () => onSendMessage?.call(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
            () => onUndo?.call(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
            () => onRedo?.call(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
            () => onSearch?.call(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
            () => onExport?.call(),

        // Session control
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
            () => onPause?.call(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
            () => onResume?.call(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
            () => onCancel?.call(),

        // View
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
            () => onToggleSidebar?.call(),
      },
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          // Default shortcuts
          ..._buildShortcuts(),
        },
        child: child,
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return {
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const NavigateIntent(-1),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const NavigateIntent(1),
      const SingleActivator(LogicalKeyboardKey.enter): SendMessageIntent(),
    };
  }

  void _navigate(int direction) {
    // Implementation for navigating through entries
  }

  void _newLine() {
    // Implementation for adding a new line
  }

  void _cancelInput() {
    // Implementation for canceling input
  }
}
