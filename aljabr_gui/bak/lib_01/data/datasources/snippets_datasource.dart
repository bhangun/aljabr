import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import '../../features/chat/models/prompt_snippet.dart';
import '../models/json_models.dart';

/// Default snippets shipped with the app — illustrates the slash-command pattern.
final List<PromptSnippet> kDefaultSnippets = [
  const PromptSnippet(
    id: 'snippet-explain',
    title: 'Explain code',
    shortcut: '/explain',
    content:
        'Explain what this code does, step by step, including any non-obvious behavior.',
  ),
  const PromptSnippet(
    id: 'snippet-refactor',
    title: 'Refactor for clarity',
    shortcut: '/refactor',
    content:
        'Refactor this code for clarity and maintainability without changing its behavior. '
        'Provide the full updated file.',
  ),
  const PromptSnippet(
    id: 'snippet-tests',
    title: 'Write tests',
    shortcut: '/tests',
    content:
        'Write comprehensive unit tests for this code, covering edge cases.',
  ),
  const PromptSnippet(
    id: 'snippet-bug',
    title: 'Find bugs',
    shortcut: '/bugs',
    content:
        'Review this code for bugs, edge cases, and potential runtime errors. List each issue found.',
  ),
  const PromptSnippet(
    id: 'snippet-optimize',
    title: 'Optimize performance',
    shortcut: '/optimize',
    content:
        'Identify performance bottlenecks in this code and suggest concrete optimizations.',
  ),
  const PromptSnippet(
    id: 'snippet-document',
    title: 'Add documentation',
    shortcut: '/docs',
    content:
        'Add clear doc comments to this code following the language\'s standard conventions.',
  ),
];

/// Handles persistence of user-defined prompt snippets.
class SnippetsDatasource {
  SnippetsDatasource(this._prefs);

  final SharedPreferences _prefs;

  Result<List<PromptSnippet>> loadSnippets() {
    try {
      final raw = _prefs.getStringList(AppConstants.kSnippets);
      if (raw == null) return Success(List.of(kDefaultSnippets));
      final snippets = raw
          .map(
            (s) => promptSnippetFromJson(jsonDecode(s) as Map<String, dynamic>),
          )
          .toList();
      return Success(snippets);
    } catch (e) {
      return Failure(StorageError('Failed to load snippets: $e'));
    }
  }

  Future<Result<void>> saveSnippets(List<PromptSnippet> snippets) async {
    try {
      final encoded = snippets.map((s) => jsonEncode(s.toJson())).toList();
      await _prefs.setStringList(AppConstants.kSnippets, encoded);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to save snippets: $e'));
    }
  }
}
