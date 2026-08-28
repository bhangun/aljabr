import 'dart:async';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

class CommandRegistry implements OwnerCleanup {
  final Map<String, AppCommand> _commands = {};
  final Map<String, Set<String>> _commandsByOwner = {};

  void register(AppCommand command, {String ownerId = 'core'}) {
    if (_commands.containsKey(command.id)) {
      throw StateError('Command already registered: ${command.id}');
    }
    _commands[command.id] = command;
    _commandsByOwner.putIfAbsent(ownerId, () => <String>{}).add(command.id);
  }

  AppCommand? get(String id) => _commands[id];

  bool contains(String id) => _commands.containsKey(id);

  List<AppCommand> get all => List.unmodifiable(_commands.values.toList());

  List<AppCommand> getAll() => all;

  List<AppCommand> search(String query) {
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            (c.subtitle?.toLowerCase().contains(q) ?? false) ||
            c.category.toLowerCase().contains(q))
        .toList();
  }

  Future<void> execute(String id, CommandContext context) async {
    final command = _commands[id];
    if (command == null) {
      throw StateError('Command not found: $id');
    }
    if (command.action != null) {
      await command.action!(context);
    }
  }

  @override
  void unregisterAllForOwner(String ownerId) {
    final ids = _commandsByOwner.remove(ownerId);
    if (ids == null) return;
    for (final id in ids) {
      _commands.remove(id);
    }
  }
}
