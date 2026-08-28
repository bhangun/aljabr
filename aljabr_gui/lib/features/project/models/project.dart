/// A repository / workspace root. Each [Project] owns many [Session]s
/// (one per agent conversation run against that codebase).
class Project {
  final String id;
  final String name;
  final String description;
  final String rootPath;
  final String? branch;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final Map<String, dynamic> metadata;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    required this.rootPath,
    this.branch,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.metadata = const {},
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? rootPath,
    String? branch,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rootPath: rootPath ?? this.rootPath,
      branch: branch ?? this.branch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'rootPath': rootPath,
        'branch': branch,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isArchived': isArchived,
        'metadata': metadata,
      };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      rootPath: json['rootPath'] as String,
      branch: json['branch'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
