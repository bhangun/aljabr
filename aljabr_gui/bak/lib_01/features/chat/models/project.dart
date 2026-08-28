import 'package:equatable/equatable.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    this.path,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? path;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({
    String? name,
    String? path,
    DateTime? updatedAt,
  }) => Project(
    id: id,
    name: name ?? this.name,
    path: path ?? this.path,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [id, name, path, createdAt, updatedAt];
}
