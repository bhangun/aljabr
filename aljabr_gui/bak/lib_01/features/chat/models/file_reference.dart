import 'package:equatable/equatable.dart';

class FileReference extends Equatable {
  const FileReference({
    required this.id,
    required this.name,
    required this.path,
    required this.content,
    required this.language,
  });

  final String id;
  final String name;
  final String path;
  final String content;
  final String language;

  FileReference copyWith({
    String? content,
    String? name,
    String? path,
    String? language,
  }) => FileReference(
    id: id,
    name: name ?? this.name,
    path: path ?? this.path,
    content: content ?? this.content,
    language: language ?? this.language,
  );

  @override
  List<Object?> get props => [id, name, path, content, language];
}
