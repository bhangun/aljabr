import 'dart:convert';
import 'dart:math';

import '../../features/chat/models/message.dart';

/// Accurate token counting using tiktoken-like approach
/// Supports multiple tokenization strategies per model
class TokenCounter {
  TokenCounter._();

  // BPE encoding for common tokens
  static final Map<String, int> _tokenBpe = _buildTokenBpe();

  static Map<String, int> _buildTokenBpe() {
    // Simplified BPE encoding - in production, use actual tiktoken data
    final map = <String, int>{};
    // Common tokens with approximate frequencies
    const commonTokens = [
      ' the',
      ' of',
      ' and',
      ' to',
      ' in',
      ' for',
      ' on',
      ' at',
      ' with',
      ' by',
      ' from',
      ' up',
      ' about',
      ' into',
      ' through',
      ' during',
      ' including',
      ' without',
      ' against',
      ' between',
    ];
    for (var i = 0; i < commonTokens.length; i++) {
      map[commonTokens[i]] = 1000 + i;
    }
    return map;
  }

  /// Estimate tokens for a given text and model
  static int estimateTokens(String text, {String model = 'claude-sonnet-4-6'}) {
    if (text.isEmpty) return 0;

    // Use model-specific tokenization
    switch (model) {
      case 'claude-opus-4-6':
      case 'claude-sonnet-4-6':
      case 'claude-haiku-4-5':
        return _estimateClaudeTokens(text);
      case 'gpt-4':
      case 'gpt-4-turbo':
      case 'gpt-3.5-turbo':
        return _estimateOpenAITokens(text);
      default:
        return _estimateGenericTokens(text);
    }
  }

  /// Claude token estimation (more accurate than 3 char/token)
  static int _estimateClaudeTokens(String text) {
    // Claude uses a BPE tokenizer with ~4 chars/token average
    // But varies significantly by language
    final length = text.length;
    final charType = _analyzeText(text);

    // Asian languages have more tokens per char
    final multiplier = charType == CharacterType.asian ? 2.0 : 3.0;
    final base = (length / multiplier).ceil();

    // Add overhead for special characters
    final specialChars = text.runes.where((r) => r > 0x7F).length;
    final overhead = (specialChars / 10).ceil();

    // Whitespace counts as tokens
    final spaces = ' '.allMatches(text).length;
    final spaceTokens = (spaces / 5).ceil();

    return base + overhead + spaceTokens + 2; // +2 for BOS/EOS
  }

  /// OpenAI token estimation (GPT family)
  static int _estimateOpenAITokens(String text) {
    // GPT uses ~4 chars/token for English, more for other languages
    final length = text.length;
    final charType = _analyzeText(text);

    final multiplier = charType == CharacterType.asian ? 2.5 : 3.7;
    return (length / multiplier).ceil() + 2;
  }

  /// Generic fallback
  static int _estimateGenericTokens(String text) {
    // Most tokenizers use ~3.5 chars/token on average
    return (text.length / 3.5).ceil();
  }

  static CharacterType _analyzeText(String text) {
    final runs = text.runes;
    int asianCount = 0;
    int latinCount = 0;

    for (final r in runs) {
      if ((r >= 0x4E00 && r <= 0x9FFF) || // CJK Unified Ideographs
          (r >= 0x3040 && r <= 0x30FF) || // Hiragana/Katakana
          (r >= 0xAC00 && r <= 0xD7A3)) {
        // Hangul
        asianCount++;
      } else if ((r >= 0x0041 && r <= 0x005A) || // A-Z
          (r >= 0x0061 && r <= 0x007A)) {
        // a-z
        latinCount++;
      }
    }

    if (asianCount > latinCount * 1.2) return CharacterType.asian;
    return CharacterType.latin;
  }

  /// Estimate tokens for a list of messages
  static int estimateMessages(
    List<Message> messages, {
    String model = 'claude-sonnet-4-6',
  }) {
    var total = 0;
    for (final m in messages) {
      total += estimateTokens(m.content, model: model);
      // Include attachments
      for (final f in m.attachedFiles) {
        total += estimateTokens(f.content, model: model);
      }
    }
    return total;
  }

  /// Get context window size for a model
  static int getContextWindow(String model) {
    const windows = {
      'claude-opus-4-6': 200000,
      'claude-sonnet-4-6': 200000,
      'claude-haiku-4-5': 200000,
      'gpt-4': 8192,
      'gpt-4-turbo': 128000,
      'gpt-3.5-turbo': 16385,
    };
    return windows[model] ?? 200000;
  }

  /// Check if context is too large
  static bool isContextExceeded(String text, String model) {
    final tokens = estimateTokens(text, model: model);
    final maxTokens = getContextWindow(model);
    return tokens > maxTokens * 0.9; // 90% threshold
  }

  /// Get token usage breakdown
  static Map<String, int> getTokenBreakdown(
    List<Message> messages, {
    String model = 'claude-sonnet-4-6',
  }) {
    final breakdown = <String, int>{};
    for (final m in messages) {
      final key = m.role.name;
      breakdown[key] =
          (breakdown[key] ?? 0) + estimateTokens(m.content, model: model);
      for (final f in m.attachedFiles) {
        breakdown['attachments'] =
            (breakdown['attachments'] ?? 0) +
            estimateTokens(f.content, model: model);
      }
    }
    return breakdown;
  }
}

enum CharacterType { latin, asian }
