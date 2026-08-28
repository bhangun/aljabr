import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../coding_agent.dart';
import 'model_provider.dart';

class DefaultProvider implements ModelProvider {
  DefaultProvider({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  @override
  String get name => 'Default';

  @override
  int getContextWindow() =>
      AppConstants.modelContextWindows['claude-sonnet-4-6'] ?? 200000;

  @override
  int getMaxOutputTokens() => 8192;

  @override
  Stream<Result<String>> streamCompletion(ModelRequest request) async* {
    final payload = request.toMap({
      'model': 'claude-sonnet-4-6',
      'stream': true,
      'system': request.systemPrompt,
    });

    try {
      final response = await _client.send(
        http.Request(
            'POST',
            Uri.parse('${AppConstants.claudeBaseUrl}/messages'),
          )
          ..headers.addAll({
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': AppConstants.anthropicVersion,
          })
          ..body = jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield Failure(_mapError(response.statusCode, body));
        return;
      }

      final buffer = StringBuffer();
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        final raw = buffer.toString();
        final lines = raw.split('\n');

        buffer.clear();
        if (!raw.endsWith('\n')) {
          buffer.write(lines.removeLast());
        } else {
          lines.removeLast();
        }

        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;
          try {
            final j = jsonDecode(data) as Map<String, dynamic>;
            final type = j['type'] as String?;
            if (type == 'content_block_delta') {
              final delta = j['delta'] as Map<String, dynamic>?;
              final text = delta?['text'] as String?;
              if (text != null && text.isNotEmpty) yield Success(text);
            }
          } catch (_) {
            // Skip malformed lines
          }
        }
      }
    } catch (e) {
      yield Failure(NetworkError('Connection failed: $e'));
    }
  }

  @override
  Future<Result<String>> complete(ModelRequest request) async {
    final payload = request.toMap({
      'model': 'claude-sonnet-4-6',
      'stream': false,
      'system': request.systemPrompt,
    });

    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.claudeBaseUrl}/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': AppConstants.anthropicVersion,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        return Failure(_mapError(response.statusCode, response.body));
      }

      final j = jsonDecode(response.body) as Map<String, dynamic>;
      final content = j['content'] as List?;
      final text = content
          ?.whereType<Map<String, dynamic>>()
          .where((b) => b['type'] == 'text')
          .map((b) => b['text'] as String)
          .join('');
      return Success(text ?? '');
    } catch (e) {
      return Failure(NetworkError('Request failed: $e'));
    }
  }

  AppError _mapError(int statusCode, String body) {
    // Same error mapping as before
    return switch (statusCode) {
      401 => ApiError('Invalid API key', type: 'auth_error'),
      429 => ApiError('Rate limited', type: 'rate_limit_error'),
      _ => ApiError('API error: $statusCode', type: 'http_$statusCode'),
    };
  }

  void dispose() => _client.close();
}
