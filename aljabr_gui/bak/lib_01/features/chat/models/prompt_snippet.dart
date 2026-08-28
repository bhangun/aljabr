import 'package:equatable/equatable.dart';

class PromptSnippet extends Equatable {
  const PromptSnippet({
    required this.id,
    required this.title,
    required this.content,
    this.shortcut,
  });

  final String id;
  final String title;
  final String content;
  final String? shortcut; // e.g. "/explain"

  PromptSnippet copyWith({String? title, String? content, String? shortcut}) =>
      PromptSnippet(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        shortcut: shortcut ?? this.shortcut,
      );

  @override
  List<Object?> get props => [id, title, content, shortcut];
}
