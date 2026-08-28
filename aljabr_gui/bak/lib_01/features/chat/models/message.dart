import 'package:equatable/equatable.dart';
import 'file_diff.dart';
import 'file_reference.dart';

enum MessageRole { user, assistant, system }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.attachedFiles = const [],
    this.diffs = const [],
    this.isStreaming = false,
    this.hasError = false,
    this.errorMessage,
    this.tokenCount,
    this.wasEdited = false,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final List<FileReference> attachedFiles;
  final List<FileDiff> diffs;
  final bool isStreaming;
  final bool hasError;
  final String? errorMessage;
  final int? tokenCount;
  final bool wasEdited;

  Message copyWith({
    String? content,
    List<FileDiff>? diffs,
    bool? isStreaming,
    bool? hasError,
    String? errorMessage,
    int? tokenCount,
    bool? wasEdited,
  }) => Message(
    id: id,
    role: role,
    content: content ?? this.content,
    createdAt: createdAt,
    attachedFiles: attachedFiles,
    diffs: diffs ?? this.diffs,
    isStreaming: isStreaming ?? this.isStreaming,
    hasError: hasError ?? this.hasError,
    errorMessage: errorMessage ?? this.errorMessage,
    tokenCount: tokenCount ?? this.tokenCount,
    wasEdited: wasEdited ?? this.wasEdited,
  );

  @override
  List<Object?> get props => [
    id,
    role,
    content,
    createdAt,
    isStreaming,
    wasEdited,
  ];
}
