
import '../chat/models/file_reference.dart';
import '../chat/models/message.dart';
import '../search/search_engine.dart';

/// Context-aware autocomplete for code and natural language
class AutocompleteEngine {
  final SearchEngine _search;

  AutocompleteEngine(this._search);

  /// Get completions based on context
  List<CompletionSuggestion> getCompletions({
    required String input,
    required List<Message> conversation,
    required List<FileReference> files,
    int limit = 5,
  }) {
    final suggestions = <CompletionSuggestion>[];

    // Detect completion type
    final completionType = _detectCompletionType(input);

    switch (completionType) {
      case CompletionType.filePath:
        suggestions.addAll(_getFilePathCompletions(input, files));
        break;
      case CompletionType.functionName:
        suggestions.addAll(_getFunctionCompletions(input, files));
        break;
      case CompletionType.import:
        suggestions.addAll(_getImportCompletions(input, files));
        break;
      case CompletionType.codeSnippet:
        suggestions.addAll(_getCodeSnippets(input, files));
        break;
      case CompletionType.naturalLanguage:
        suggestions.addAll(_getNaturalLanguageCompletions(input, conversation));
        break;
    }

    return suggestions.take(limit).toList();
  }

  CompletionType _detectCompletionType(String input) {
    if (input.contains('@')) return CompletionType.filePath;
    if (RegExp(r'^\s*import\s+').hasMatch(input)) return CompletionType.import;
    if (RegExp(r'^\s*(def|function|fun|fn)\s+').hasMatch(input)) {
      return CompletionType.functionName;
    }
    if (input.contains('\n')) return CompletionType.codeSnippet;
    return CompletionType.naturalLanguage;
  }

  List<CompletionSuggestion> _getFilePathCompletions(String input, List<FileReference> files) {
    final suggestions = <CompletionSuggestion>[];
    final parts = input.split('@');
    final query = parts.last.trim().toLowerCase();

    for (final file in files) {
      if (file.name.toLowerCase().contains(query)) {
        suggestions.add(CompletionSuggestion(
          label: file.name,
          detail: file.path,
          kind: SuggestionKind.file,
          insertText: file.name,
          score: _calculateRelevance(query, file.name),
        ));
      }
    }
    return suggestions;
  }

  List<CompletionSuggestion> _getFunctionCompletions(String input, List<FileReference> files) {
    final suggestions = <CompletionSuggestion>[];
    final functionRegex = RegExp(
      r'^\s*(def|function|fun|fn)\s+([a-zA-Z_][a-zA-Z0-9_]*)',
    );
    final match = functionRegex.firstMatch(input);
    if (match == null) return suggestions;

    final prefix = match.group(2)?.toLowerCase() ?? '';

    // Scan files for function definitions
    for (final file in files) {
      final functions = _extractFunctions(file.content);
      for (final func in functions) {
        if (func.name.toLowerCase().startsWith(prefix)) {
          suggestions.add(CompletionSuggestion(
            label: func.name,
            detail: '${func.parameters} -> ${func.returnType}',
            kind: SuggestionKind.function,
            insertText: func.name,
            score: _calculateRelevance(prefix, func.name),
          ));
        }
      }
    }
    return suggestions;
  }

  List<CompletionSuggestion> _getImportCompletions(String input, List<FileReference> files) {
    final suggestions = <CompletionSuggestion>[];
    final query = input.replaceFirst('import', '').trim().toLowerCase();

    for (final file in files) {
      if (file.name.toLowerCase().contains(query)) {
        suggestions.add(CompletionSuggestion(
          label: file.name,
          detail: file.path,
          kind: SuggestionKind.import,
          insertText: "import '${file.path}'",
          score: _calculateRelevance(query, file.name),
        ));
      }
    }
    return suggestions;
  }

  List<CompletionSuggestion> _getCodeSnippets(String input, List<FileReference> files) {
    // Common code snippets
    const snippets = {
      'class': r'class ${1:Name} {\n  ${2: // TODO}\n}',
      'interface': r'interface ${1:Name} {\n  ${2: // TODO}\n}',
      'function': r'function ${1:name}(${2:params}) {\n  ${3: // TODO}\n}',
      'for': r'for (let i = 0; i < ${1:array.length}; i++) {\n  ${2: // TODO}\n}',
      'if': r'if (${1:condition}) {\n  ${2: // TODO}\n}',
    };

    final suggestions = <CompletionSuggestion>[];
    final query = input.trim().toLowerCase();

    for (final entry in snippets.entries) {
      if (entry.key.contains(query) || query.contains(entry.key)) {
        suggestions.add(CompletionSuggestion(
          label: entry.key,
          detail: entry.value.split('\n').first,
          kind: SuggestionKind.snippet,
          insertText: entry.value,
          score: _calculateRelevance(query, entry.key),
        ));
      }
    }
    return suggestions;
  }

  List<CompletionSuggestion> _getNaturalLanguageCompletions(
    String input,
    List<Message> conversation,
  ) {
    // Simple completion based on conversation history
    final suggestions = <CompletionSuggestion>[];
    final words = input.trim().split(' ');
    final lastWord = words.isNotEmpty ? words.last.toLowerCase() : '';

    // Look for common follow-ups in conversation
    final followUps = <String, String>{};
    for (final message in conversation) {
      if (message.role == MessageRole.assistant) {
        // Extract key phrases
        final phrases = _extractPhrases(message.content);
        for (final phrase in phrases) {
          if (phrase.startsWith(lastWord)) {
            followUps[phrase] = phrase;
          }
        }
      }
    }

    for (final phrase in followUps.values.take(3)) {
      suggestions.add(CompletionSuggestion(
        label: phrase,
        detail: 'From previous conversation',
        kind: SuggestionKind.text,
        insertText: phrase,
        score: 1.0,
      ));
    }

    return suggestions;
  }

  List<FunctionDefinition> _extractFunctions(String code) {
    final functions = <FunctionDefinition>[];
    final regex = RegExp(
      r'^\s*(def|function|fun|fn)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*[:{]\s*(?:\w+\s*)?([^{]*){',
      multiLine: true,
    );

    for (final match in regex.allMatches(code)) {
      functions.add(FunctionDefinition(
        name: match.group(2) ?? '',
        parameters: match.group(3) ?? '',
        returnType: match.group(4)?.trim() ?? 'void',
      ));
    }
    return functions;
  }

  List<String> _extractPhrases(String text) {
    final phrases = <String>[];
    final sentences = text.split(RegExp(r'[.!?]'));
    for (final sentence in sentences) {
      final words = sentence.trim().split(RegExp(r'\s+'));
      if (words.length > 3) {
        phrases.add(words.take(3).join(' '));
      }
    }
    return phrases;
  }

  double _calculateRelevance(String query, String target) {
    if (query.isEmpty) return 0.5;
    final lowerQuery = query.toLowerCase();
    final lowerTarget = target.toLowerCase();

    if (lowerTarget == lowerQuery) return 1.0;
    if (lowerTarget.startsWith(lowerQuery)) return 0.8;
    if (lowerTarget.contains(lowerQuery)) return 0.5;

    // Calculate similarity
    final common = lowerQuery.split('').where((c) => lowerTarget.contains(c)).length;
    return common / lowerQuery.length;
  }
}

/// Completion suggestion types
enum CompletionType {
  filePath,
  functionName,
  import,
  codeSnippet,
  naturalLanguage,
}

enum SuggestionKind {
  file,
  function,
  import,
  snippet,
  text,
}

/// A single completion suggestion
class CompletionSuggestion {
  const CompletionSuggestion({
    required this.label,
    required this.detail,
    required this.kind,
    required this.insertText,
    required this.score,
  });

  final String label;
  final String detail;
  final SuggestionKind kind;
  final String insertText;
  final double score;
}

/// Function definition extracted from code
class FunctionDefinition {
  const FunctionDefinition({
    required this.name,
    required this.parameters,
    required this.returnType,
  });

  final String name;
  final String parameters;
  final String returnType;
}