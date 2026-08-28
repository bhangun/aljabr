import 'composer_context.dart';

enum ComposerMode { ask, edit, review, agent }

enum ComposerStatus { idle, composing, submitting, streaming, completed, error }

class ComposerState {
  final ComposerMode mode;
  final ComposerStatus status;
  final String text;
  final List<ComposerContext> contexts;

  const ComposerState({
    this.mode = ComposerMode.ask,
    this.status = ComposerStatus.idle,
    this.text = '',
    this.contexts = const [],
  });

  ComposerState copyWith({
    ComposerMode? mode,
    ComposerStatus? status,
    String? text,
    List<ComposerContext>? contexts,
  }) {
    return ComposerState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      text: text ?? this.text,
      contexts: contexts ?? this.contexts,
    );
  }
}
