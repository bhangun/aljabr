enum SkillType { rule, skill }

class SkillItem {
  final String id;
  final String name;
  final double percentage;
  final int count;
  final bool isExpanded;
  final SkillType type;
  final List<dynamic> items;

  const SkillItem({
    required this.id,
    required this.name,
    required this.percentage,
    required this.count,
    required this.isExpanded,
    required this.type,
    required this.items,
  });

  SkillItem copyWith({
    String? id,
    String? name,
    double? percentage,
    int? count,
    bool? isExpanded,
    SkillType? type,
    List<dynamic>? items,
  }) {
    return SkillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      count: count ?? this.count,
      isExpanded: isExpanded ?? this.isExpanded,
      type: type ?? this.type,
      items: items ?? this.items,
    );
  }
}
