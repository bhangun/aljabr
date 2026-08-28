import 'package:equatable/equatable.dart';

import 'file_reference.dart';
import 'message.dart';

class Session extends Equatable {
  const Session({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.files = const [],
    this.systemPrompt,
    this.isPinned = false,
    this.tags = const [],
    this.projectId,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;
  final List<FileReference> files;
  final String? systemPrompt;
  final bool isPinned;
  final List<String> tags;
  final String? projectId;

  Session copyWith({
    String? title,
    DateTime? updatedAt,
    List<Message>? messages,
    List<FileReference>? files,
    String? systemPrompt,
    bool? isPinned,
    List<String>? tags,
    String? projectId,
  }) => Session(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    messages: messages ?? this.messages,
    files: files ?? this.files,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    isPinned: isPinned ?? this.isPinned,
    tags: tags ?? this.tags,
    projectId: projectId ?? this.projectId,
  );

  String get preview {
    if (messages.isEmpty) return 'No messages yet';
    final last = messages.last;
    return last.content.length > 80
        ? '${last.content.substring(0, 80)}…'
        : last.content;
  }

  int get messageCount => messages.length;

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt, isPinned, projectId];
}
