class RuleItem {
  final String id;
  final String name;
  final bool isBreakdown;
  final String? description;

  const RuleItem({
    required this.id,
    required this.name,
    required this.isBreakdown,
    this.description,
  });
}
