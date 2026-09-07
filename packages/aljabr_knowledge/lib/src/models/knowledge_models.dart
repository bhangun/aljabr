class SkillDescriptor {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isEnabled;
  final List<String> triggers;

  const SkillDescriptor({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'General',
    this.isEnabled = true,
    this.triggers = const [],
  });
}

class AgentMemoryRecord {
  final String id;
  final String scope;
  final String key;
  final String value;
  final DateTime createdAt;

  const AgentMemoryRecord({
    required this.id,
    required this.scope,
    required this.key,
    required this.value,
    required this.createdAt,
  });
}
