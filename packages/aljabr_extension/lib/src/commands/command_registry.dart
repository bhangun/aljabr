import '../extensions/contribution.dart';
import 'app_command.dart';

class CommandRegistry implements OwnerCleanup {
  final Map<String, AppCommand> _commands = {};
  final Map<String, String> _owners = {};

  void register(AppCommand command, {String? ownerId}) {
    if (_commands.containsKey(command.id)) {
      throw StateError('Command already registered: ${command.id}');
    }
    _commands[command.id] = command;
    if (ownerId != null) {
      _owners[command.id] = ownerId;
    }
  }

  @override
  void unregisterAllForOwner(String ownerId) {
    final ids = _owners.entries
        .where((entry) => entry.value == ownerId)
        .map((entry) => entry.key)
        .toList();

    for (final id in ids) {
      _commands.remove(id);
      _owners.remove(id);
    }
  }

  List<AppCommand> get all => List.unmodifiable(_commands.values.toList());

  List<AppCommand> getAll() => all;
  
  AppCommand? get(String id) => _commands[id];

  List<AppCommand> search(String query) {
    if (query.isEmpty) {
      return all;
    }
    
    final lowerQuery = query.toLowerCase();
    return _commands.values.where((cmd) {
      return cmd.title.toLowerCase().contains(lowerQuery) || 
             cmd.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
