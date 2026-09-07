enum WorkType {
  feature,
  bug,
  refactor,
  review,
  research;

  String get label {
    switch (this) {
      case WorkType.feature:
        return 'Feature';
      case WorkType.bug:
        return 'Bug Fix';
      case WorkType.refactor:
        return 'Refactor';
      case WorkType.review:
        return 'Code Review';
      case WorkType.research:
        return 'Research';
    }
  }
}

enum WorkStatus {
  todo,
  inProgress,
  verified,
  completed,
  failed;

  bool get isTerminal => this == WorkStatus.completed || this == WorkStatus.failed;
}

class WorkItem {
  final String id;
  final String workspaceId;
  final WorkType type;
  final String title;
  final String description;
  final WorkStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkItem({
    required this.id,
    required this.workspaceId,
    required this.type,
    required this.title,
    required this.description,
    this.status = WorkStatus.todo,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  WorkItem copyWith({
    String? id,
    String? workspaceId,
    WorkType? type,
    String? title,
    String? description,
    WorkStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkItem(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'type': type.name,
        'title': title,
        'description': description,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String? ?? '',
      type: WorkType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => WorkType.feature,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: WorkStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WorkStatus.todo,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
