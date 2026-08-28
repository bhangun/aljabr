import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/chat/models/prompt_snippet.dart';
import 'infrastructure_providers.dart';

class SnippetsNotifier extends StateNotifier<List<PromptSnippet>> {
  SnippetsNotifier(this._ref) : super([]) {
    _load();
  }

  final Ref _ref;

  void _load() {
    final result = _ref.read(snippetsRepositoryProvider).getSnippets();
    result.fold(onSuccess: (s) => state = s, onFailure: (_) {});
  }

  Future<void> addSnippet({
    required String title,
    required String content,
    String? shortcut,
  }) async {
    final snippet = _ref
        .read(snippetsRepositoryProvider)
        .createSnippet(title: title, content: content, shortcut: shortcut);
    final result = await _ref
        .read(snippetsRepositoryProvider)
        .addSnippet(snippet);
    result.fold(
      onSuccess: (_) => state = [...state, snippet],
      onFailure: (_) {},
    );
  }

  Future<void> updateSnippet(PromptSnippet snippet) async {
    final result = await _ref
        .read(snippetsRepositoryProvider)
        .updateSnippet(snippet);
    result.fold(
      onSuccess: (_) =>
          state = state.map((s) => s.id == snippet.id ? snippet : s).toList(),
      onFailure: (_) {},
    );
  }

  Future<void> deleteSnippet(String id) async {
    final result = await _ref
        .read(snippetsRepositoryProvider)
        .deleteSnippet(id);
    result.fold(
      onSuccess: (_) => state = state.where((s) => s.id != id).toList(),
      onFailure: (_) {},
    );
  }

  /// Resolve a slash-command at the start of [input], if any, returning the
  /// snippet's full content. Returns null when there's no match.
  PromptSnippet? matchShortcut(String input) {
    final trimmed = input.trim();
    if (!trimmed.startsWith('/')) return null;
    final firstWord = trimmed.split(RegExp(r'\s')).first;
    for (final s in state) {
      if (s.shortcut == firstWord) return s;
    }
    return null;
  }
}

final snippetsProvider =
    StateNotifierProvider<SnippetsNotifier, List<PromptSnippet>>((ref) {
      return SnippetsNotifier(ref);
    });
