import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized keyboard shortcut management
class ShortcutManager {
  ShortcutManager._();
  static final ShortcutManager _instance = ShortcutManager._();
  static ShortcutManager get instance => _instance;

  final Map<LogicalKeyboardKey, ShortcutAction> _shortcuts = {};
  final Map<String, ShortcutAction> _shortcutNames = {};

  void register(ShortcutAction action) {
    for (final key in action.keys) {
      _shortcuts[key] = action;
    }
    _shortcutNames[action.name] = action;
  }

  void unregister(String name) {
    final action = _shortcutNames[name];
    if (action != null) {
      for (final key in action.keys) {
        _shortcuts.remove(key);
      }
      _shortcutNames.remove(name);
    }
  }

  bool handleKey(KeyEvent event, BuildContext context) {
    if (event is! KeyDownEvent) return false;

    final action = _shortcuts[event.logicalKey];
    if (action != null && action.isModifierMatch(event)) {
      action.execute(context);
      return true;
    }
    return false;
  }

  List<ShortcutAction> get allActions => _shortcutNames.values.toList();

  // Default shortcuts
  static const defaultShortcuts = [
    ShortcutAction(
      name: 'New Session',
      keys: [LogicalKeyboardKey.keyN],
      meta: true,
      icon: Icons.add,
    ),
    ShortcutAction(
      name: 'Search',
      keys: [LogicalKeyboardKey.keyF],
      meta: true,
      icon: Icons.search,
    ),
    ShortcutAction(
      name: 'Command Palette',
      keys: [LogicalKeyboardKey.keyK],
      meta: true,
      icon: Icons.palette,
    ),
    ShortcutAction(
      name: 'Toggle Sidebar',
      keys: [LogicalKeyboardKey.backslash],
      meta: true,
      icon: Icons.view_sidebar,
    ),
    ShortcutAction(
      name: 'Save',
      keys: [LogicalKeyboardKey.keyS],
      meta: true,
      icon: Icons.save,
    ),
    ShortcutAction(
      name: 'Find in Files',
      keys: [LogicalKeyboardKey.keyF],
      meta: true,
      shift: true,
      icon: Icons.find_in_page,
    ),
    ShortcutAction(
      name: 'Send Message',
      keys: [LogicalKeyboardKey.enter],
      icon: Icons.send,
    ),
  ];
}

/// A registered shortcut action
class ShortcutAction {
  const ShortcutAction({
    required this.name,
    required this.keys,
    this.meta = false,
    this.ctrl = false,
    this.shift = false,
    this.alt = false,
    this.icon,
    this.description,
  });

  final String name;
  final List<LogicalKeyboardKey> keys;
  final bool meta;
  final bool ctrl;
  final bool shift;
  final bool alt;
  final IconData? icon;
  final String? description;

  bool isModifierMatch(KeyEvent event) {
    final pressed = RawKeyboard.instance.keysPressed;
    bool hasMeta = pressed.contains(LogicalKeyboardKey.metaLeft) || pressed.contains(LogicalKeyboardKey.metaRight) || pressed.contains(LogicalKeyboardKey.meta);
    bool hasCtrl = pressed.contains(LogicalKeyboardKey.controlLeft) || pressed.contains(LogicalKeyboardKey.controlRight) || pressed.contains(LogicalKeyboardKey.control);
    bool hasShift = pressed.contains(LogicalKeyboardKey.shiftLeft) || pressed.contains(LogicalKeyboardKey.shiftRight) || pressed.contains(LogicalKeyboardKey.shift);
    bool hasAlt = pressed.contains(LogicalKeyboardKey.altLeft) || pressed.contains(LogicalKeyboardKey.altRight) || pressed.contains(LogicalKeyboardKey.alt);

    if (meta && !hasMeta) return false;
    if (ctrl && !hasCtrl) return false;
    if (shift && !hasShift) return false;
    if (alt && !hasAlt) return false;
    return true;
  }

  void execute(BuildContext context) {
    // Find and execute the corresponding callback
    final scope = ShortcutScope.of(context);
    scope?.executeAction(name);
  }

  String get displayKey {
    final parts = <String>[];
    if (meta) parts.add('⌘');
    if (ctrl) parts.add('⌃');
    if (shift) parts.add('⇧');
    if (alt) parts.add('⌥');
    parts.addAll(keys.map((k) => k.keyLabel));
    return parts.join('+');
  }
}

/// Scope for shortcut actions
class ShortcutScope extends InheritedWidget {
  const ShortcutScope({super.key, required super.child, required this.actions});

  final Map<String, VoidCallback> actions;

  static ShortcutScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShortcutScope>();
  }

  void executeAction(String name) {
    actions[name]?.call();
  }

  @override
  bool updateShouldNotify(ShortcutScope oldWidget) {
    return actions != oldWidget.actions;
  }
}

/// Extension for accessing shortcut state
extension ShortcutExtension on BuildContext {
  bool isShortcutPressed(LogicalKeyboardKey key, {bool meta = false}) {
    final raw = RawKeyboard.instance.keysPressed;
    if (!raw.contains(key)) return false;
    if (meta && !raw.contains(LogicalKeyboardKey.meta)) return false;
    return true;
  }
}
