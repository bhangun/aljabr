import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import '../../features/chat/models/message.dart';
import '../../features/chat/models/project.dart';
import '../../features/chat/models/session.dart';
import '../models/json_models.dart';

class WayangProApiDatasource {
  WayangProApiDatasource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Stream<Result<String>> streamCompletion({
    required String baseUrl,
    required String model,
    required List<Message> messages,
    required int maxTokens,
    String? systemPrompt,
    String? providerId,
  }) async* {
    final payloadMessages = _sanitizeMessages(messages);

    if (payloadMessages.isEmpty) {
      yield Failure(ValidationError('No messages to send'));
      return;
    }

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      payloadMessages.insert(0, Message(
        id: 'sys',
        role: MessageRole.system,
        content: systemPrompt,
        createdAt: DateTime.now(),
      ));
    }

    final body = jsonEncode({
      'model': model,
      'providerId': providerId,
      'maxTokens': maxTokens,
      'messages': payloadMessages.map(_toApiMessage).toList(),
    });

    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    late http.StreamedResponse response;
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$url/pro/api/v1/agent/chat'),
      )
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        })
        ..body = body;

      response = await _client.send(request);
    } catch (e) {
      yield Failure(NetworkError('Connection failed: $e'));
      return;
    }

    if (response.statusCode != 200) {
      final respBody = await response.stream.bytesToString();
      yield Failure(ApiError('HTTP ${response.statusCode}: $respBody'));
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
            }
          } catch (_) {
          }
        }
      }
    } catch (e) {
      yield Failure(NetworkError('Stream interrupted: $e'));
    }
  }

  Future<Result<String>> complete({
    required String baseUrl,
    required String model,
    required List<Message> messages,
    required int maxTokens,
    String? systemPrompt,
    String? providerId,
  }) async {
    // For now, if fallback is needed, we can just consume streamCompletion fully
    // Or we implement a non-streaming endpoint.
    final buffer = StringBuffer();
    try {
      await for (final result in streamCompletion(
        baseUrl: baseUrl,
        model: model,
        messages: messages,
        maxTokens: maxTokens,
        systemPrompt: systemPrompt,
        providerId: providerId,
      )) {
        result.fold(
          onSuccess: (text) => buffer.write(text),
          onFailure: (err) => throw err,
        );
      }
      return Success(buffer.toString());
    } catch (e) {
      return Failure(NetworkError('Request failed: $e'));
    }
  }

  List<Message> _sanitizeMessages(List<Message> messages) {
    return messages
        .where((m) => m.role != MessageRole.system)
        .where((m) => !(m.isStreaming && m.content.isEmpty))
        .where((m) => m.content.trim().isNotEmpty)
        .toList();
  }

  Future<Result<List<Project>>> getProjects(String baseUrl) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.get(Uri.parse('$url/pro/api/v1/projects'));
      if (response.statusCode != 200) {
        return Failure(ApiError('HTTP ${response.statusCode}'));
      }
      final list = jsonDecode(response.body) as List;
      return Success(list.map((e) => projectFromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<Project>> createProject(String baseUrl, String name) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.post(
        Uri.parse('$url/pro/api/v1/projects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      return Success(projectFromJson(jsonDecode(response.body) as Map<String, dynamic>));
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<List<Session>>> getSessions(String baseUrl, String projectId) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.get(Uri.parse('$url/pro/api/v1/projects/$projectId/sessions'));
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      final list = jsonDecode(response.body) as List;
      return Success(list.map((e) => sessionFromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<Session>> createSession(String baseUrl, String projectId, String title) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.post(
        Uri.parse('$url/pro/api/v1/projects/$projectId/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      return Success(sessionFromJson(jsonDecode(response.body) as Map<String, dynamic>));
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<Session>> updateSession(String baseUrl, String projectId, Session session) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.put(
        Uri.parse('$url/pro/api/v1/projects/$projectId/sessions/${session.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': session.title,
          'isPinned': session.isPinned,
          if (session.systemPrompt != null) 'systemPrompt': session.systemPrompt,
          'tags': session.tags,
        }),
      );
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      return Success(sessionFromJson(jsonDecode(response.body) as Map<String, dynamic>));
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<void>> updateSessionTranscript(String baseUrl, String projectId, String sessionId, List<Message> messages) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.put(
        Uri.parse('$url/pro/api/v1/projects/$projectId/sessions/$sessionId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messages.map((m) => m.toJson()).toList()),
      );
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      return const Success(null);
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<void>> deleteSession(String baseUrl, String projectId, String sessionId) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.delete(Uri.parse('$url/pro/api/v1/projects/$projectId/sessions/$sessionId'));
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      return const Success(null);
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<Session>> duplicateSession(String baseUrl, String projectId, String sessionId, String newTitle) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.post(
        Uri.parse('$url/pro/api/v1/projects/$projectId/sessions/$sessionId/clone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': newTitle}),
      );
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      return Success(sessionFromJson(jsonDecode(response.body) as Map<String, dynamic>));
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Future<Result<List<Message>>> getSessionTranscript(String baseUrl, String projectId, String sessionId) async {
    final url = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    try {
      final response = await _client.get(Uri.parse('$url/pro/api/v1/projects/$projectId/sessions/$sessionId'));
      if (response.statusCode != 200) return Failure(ApiError('HTTP ${response.statusCode}'));
      final list = jsonDecode(response.body) as List;
      return Success(list.map((e) => messageFromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Failure(NetworkError(e.toString()));
    }
  }

  Map<String, dynamic> _toApiMessage(Message m) => {
    'role': m.role == MessageRole.user ? 'user' : (m.role == MessageRole.system ? 'system' : 'assistant'),
    'content': _buildContent(m),
  };

  String _buildContent(Message message) {
    if (message.attachedFiles.isEmpty) return message.content;
    final buffer = StringBuffer(message.content);
    buffer.writeln();
    for (final file in message.attachedFiles) {
      buffer.writeln('```${file.language} // ${file.path}\n${file.content}\n```');
    }
    return buffer.toString();
  }

  void dispose() => _client.close();
}
