import '../../core/utils/extensions.dart';
import '../../core/utils/result.dart';

import '../../features/chat/models/prompt_snippet.dart';
import '../datasources/snippets_datasource.dart';

class SnippetsRepository {
  SnippetsRepository(this._datasource);

  final SnippetsDatasource _datasource;

  Result<List<PromptSnippet>> getSnippets() => _datasource.loadSnippets();

  Future<Result<void>> addSnippet(PromptSnippet snippet) async {
    final result = getSnippets();
    return result.fold(
      onSuccess: (list) => _datasource.saveSnippets([...list, snippet]),
      onFailure: (e) async => Failure(e),
    );
  }

  Future<Result<void>> updateSnippet(PromptSnippet snippet) async {
    final result = getSnippets();
    return result.fold(
      onSuccess: (list) {
        final updated = list
            .map((s) => s.id == snippet.id ? snippet : s)
            .toList();
        return _datasource.saveSnippets(updated);
      },
      onFailure: (e) async => Failure(e),
    );
  }

  Future<Result<void>> deleteSnippet(String id) async {
    final result = getSnippets();
    return result.fold(
      onSuccess: (list) {
        final updated = list.where((s) => s.id != id).toList();
        return _datasource.saveSnippets(updated);
      },
      onFailure: (e) async => Failure(e),
    );
  }

  PromptSnippet createSnippet({
    required String title,
    required String content,
    String? shortcut,
  }) => PromptSnippet(
    id: generateId(),
    title: title,
    content: content,
    shortcut: shortcut,
  );
}
