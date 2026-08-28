import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import '../../features/chat/models/message.dart';

/// Handles all Claude API communication.
/// Streaming events are emitted via [Stream<Result<String>>] text deltas.
class ClaudeApiDatasource {
  ClaudeApiDatasource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Send messages and stream back text deltas.
  /// Empty/streaming-placeholder messages are excluded automatically.
  Stream<Result<String>> streamCompletion({
    required String apiKey,
    required String model,
    required List<Message> messages,
    required int maxTokens,
    String? systemPrompt,
  }) async* {
    final payloadMessages = _sanitizeMessages(messages);

    if (payloadMessages.isEmpty) {
      yield Failure(ValidationError('No messages to send'));
      return;
    }

    final body = jsonEncode({
      'model': model,
      'max_tokens': maxTokens,
      'stream': true,
      if (systemPrompt != null && systemPrompt.isNotEmpty)
        'system': systemPrompt,
      'messages': payloadMessages.map(_toApiMessage).toList(),
    });

    late http.StreamedResponse response;
    try {
      final request =
          http.Request(
              'POST',
              Uri.parse('${AppConstants.claudeBaseUrl}/messages'),
            )
            ..headers.addAll({
              'Content-Type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': AppConstants.anthropicVersion,
            })
            ..body = body;

      response = await _client.send(request);
    } catch (e) {
      yield Failure(NetworkError('Connection failed: $e'));
      return;
    }

    if (response.statusCode != 200) {
      final respBody = await response.stream.bytesToString();
      yield Failure(_mapHttpError(response.statusCode, respBody));
      return;
    }

    final buffer = StringBuffer();
    try {
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
            } else if (type == 'error') {
              final error = j['error'] as Map<String, dynamic>?;
              yield Failure(
                ApiError(
                  error?['message'] as String? ?? 'Unknown stream error',
                  type: error?['type'] as String?,
                ),
              );
              return;
            }
          } catch (_) {
            // Skip malformed SSE lines silently — partial frame, will complete next chunk.
          }
        }
      }
    } catch (e) {
      yield Failure(NetworkError('Stream interrupted: $e'));
    }
  }

  /// Non-streaming single call.
  Future<Result<String>> complete({
    required String apiKey,
    required String model,
    required List<Message> messages,
    required int maxTokens,
    String? systemPrompt,
  }) async {
    final payloadMessages = _sanitizeMessages(messages);
    if (payloadMessages.isEmpty) {
      return const Failure(ValidationError('No messages to send'));
    }

    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.claudeBaseUrl}/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': AppConstants.anthropicVersion,
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': maxTokens,
          if (systemPrompt != null && systemPrompt.isNotEmpty)
            'system': systemPrompt,
          'messages': payloadMessages.map(_toApiMessage).toList(),
        }),
      );

      if (response.statusCode != 200) {
        return Failure(_mapHttpError(response.statusCode, response.body));
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

  // ── Private ────────────────────────────────────────────────────────────────

  /// Drops system-role entries and any empty/in-flight streaming placeholder
  /// so we never send a blank assistant turn to the API.
  List<Message> _sanitizeMessages(List<Message> messages) {
    return messages
        .where((m) => m.role != MessageRole.system)
        .where((m) => !(m.isStreaming && m.content.isEmpty))
        .where((m) => m.content.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _toApiMessage(Message m) => {
    'role': m.role == MessageRole.user ? 'user' : 'assistant',
    'content': _buildContent(m),
  };

  dynamic _buildContent(Message message) {
    if (message.attachedFiles.isEmpty) return message.content;

    final parts = <Map<String, dynamic>>[
      {'type': 'text', 'text': message.content},
    ];
    for (final file in message.attachedFiles) {
      parts.add({
        'type': 'text',
        'text': '```${file.language} // ${file.path}\n${file.content}\n```',
      });
    }
    return parts;
  }

  AppError _mapHttpError(int statusCode, String body) {
    final message = _parseApiError(body, statusCode);
    return switch (statusCode) {
      401 => ApiError(
        'Invalid API key. Check Settings → Anthropic API.',
        type: 'auth_error',
      ),
      403 => ApiError('Access denied: $message', type: 'permission_error'),
      429 => ApiError(
        'Rate limited — please wait a moment and retry.',
        type: 'rate_limit_error',
      ),
      >= 500 => NetworkError(
        'Anthropic service error ($statusCode): $message',
        statusCode: statusCode,
      ),
      _ => ApiError(message, type: 'http_$statusCode'),
    };
  }

  String _parseApiError(String body, int statusCode) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      final error = j['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? 'HTTP $statusCode';
    } catch (_) {
      return 'HTTP $statusCode';
    }
  }

  void dispose() => _client.close();
}
