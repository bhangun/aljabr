import 'dart:collection';
import '../chat/models/message.dart';
import '../chat/models/session.dart';

/// Full-text search engine for sessions and messages
class SearchEngine {
  final Map<String, List<SearchIndex>> _index = {};
  final Map<String, Session> _sessions = {};

  /// Index all sessions for searching
  void indexSessions(List<Session> sessions) {
    _index.clear();
    _sessions.clear();

    for (final session in sessions) {
      _sessions[session.id] = session;
      _indexSession(session);
    }
  }

  void _indexSession(Session session) {
    // Index title
    _addToIndex(session.id, session.title, 3.0);

    // Index messages
    for (final message in session.messages) {
      final weight = message.role == MessageRole.assistant ? 1.0 : 1.5;
      _addToIndex(session.id, message.content, weight);

      // Index attachments
      for (final file in message.attachedFiles) {
        _addToIndex(session.id, file.content, 0.5);
      }
    }

    // Index system prompt
    if (session.systemPrompt != null) {
      _addToIndex(session.id, session.systemPrompt!, 0.8);
    }
  }

  void _addToIndex(String sessionId, String text, double weight) {
    final words = _tokenize(text);
    for (final word in words) {
      final key = word.toLowerCase();
      if (!_index.containsKey(key)) {
        _index[key] = [];
      }
      _index[key]!.add(
        SearchIndex(
          sessionId: sessionId,
          weight: weight,
          context: _extractContext(text, word),
        ),
      );
    }
  }

  /// Search for sessions matching query
  SearchResult search(String query, {int limit = 10}) {
    if (query.isEmpty) {
      return SearchResult(scores: {});
    }

    final tokens = _tokenize(query);
    final scores = <String, double>{};

    for (final token in tokens) {
      final key = token.toLowerCase();
      final matches = _index[key];
      if (matches != null) {
        for (final match in matches) {
          scores[match.sessionId] =
              (scores[match.sessionId] ?? 0) + match.weight;
        }
      }
    }

    // Apply boosts for exact phrase matches
    if (tokens.length > 1) {
      final phrase = tokens.join(' ');
      for (final session in _sessions.values) {
        if (session.title.toLowerCase().contains(phrase.toLowerCase())) {
          scores[session.id] = (scores[session.id] ?? 0) + 5.0;
        }
      }
    }

    // Sort by score
    final sorted = scores.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get sessions in order
    final ranked = sorted.take(limit).map((e) {
      final session = _sessions[e.key]!;
      return RankedSession(
        session: session,
        score: e.value,
        highlight: _getHighlight(session, query),
      );
    }).toList();

    return SearchResult(scores: scores, ranked: ranked);
  }

  List<String> _tokenize(String text) {
    // Split by word boundaries, keep alphanumeric
    return text
        .split(RegExp(r'[^\w\s]'))
        .expand((s) => s.split(RegExp(r'\s+')))
        .where((w) => w.length > 1)
        .toList();
  }

  String _extractContext(String text, String word) {
    final index = text.toLowerCase().indexOf(word.toLowerCase());
    if (index == -1) return word;

    final start = (index - 20).clamp(0, text.length);
    final end = (index + word.length + 20).clamp(0, text.length);

    var context = text.substring(start, end);
    if (start > 0) context = '...$context';
    if (end < text.length) context = '$context...';

    return context;
  }

  String? _getHighlight(Session? session, String query) {
    if (session == null) return null;
    final tokens = _tokenize(query);
    for (final message in session.messages) {
      for (final token in tokens) {
        final index = message.content.toLowerCase().indexOf(
          token.toLowerCase(),
        );
        if (index != -1) {
          final start = (index - 30).clamp(0, message.content.length);
          final end = (index + token.length + 30).clamp(
            0,
            message.content.length,
          );
          var highlight = message.content.substring(start, end);
          if (start > 0) highlight = '...$highlight';
          if (end < message.content.length) highlight = '$highlight...';
          return highlight;
        }
      }
    }
    return null;
  }

  /// Get autocomplete suggestions
  List<String> autocomplete(String prefix) {
    if (prefix.isEmpty) return [];

    final results = <String>[];
    final lower = prefix.toLowerCase();
    for (final key in _index.keys) {
      if (key.startsWith(lower) && !results.contains(key)) {
        results.add(key);
        if (results.length >= 10) break;
      }
    }
    return results;
  }
}

/// Search index entry
class SearchIndex {
  const SearchIndex({
    required this.sessionId,
    required this.weight,
    required this.context,
  });

  final String sessionId;
  final double weight;
  final String context;
}

/// Search result
class SearchResult {
  const SearchResult({required this.scores, this.ranked = const []});

  final Map<String, double> scores;
  final List<RankedSession> ranked;

  bool get isEmpty => scores.isEmpty;
  int get count => scores.length;
}

/// Ranked session result
class RankedSession {
  const RankedSession({
    required this.session,
    required this.score,
    this.highlight,
  });

  final Session session;
  final double score;
  final String? highlight;
}
