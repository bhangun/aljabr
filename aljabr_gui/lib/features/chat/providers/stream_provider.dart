import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import '../../../utils/logger.dart';
import '../../project/models/session_statusx.dart';
import '../models/plan_step.dart';
import '../models/tool_call.dart';
import 'chat_transcript_provider.dart';
import 'session_provider.dart';

enum ConnectionStatus { connecting, connected, disconnected, error }

class StreamControllerNotifier extends StateNotifier<ConnectionStatus> {
  WebSocketChannel? _channel;
  final Ref _ref;
  final String sessionId;

  StreamControllerNotifier(this._ref, this.sessionId)
      : super(ConnectionStatus.disconnected) {
    _connect();
  }

  Future<void> _connect() async {
    state = ConnectionStatus.connecting;
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://api.wayang.ai/ws/sessions/$sessionId/stream'),
      );

      _channel!.stream.listen(
        (data) => _handleStreamData(data),
        onError: (error) {
          state = ConnectionStatus.error;
          logDebug('WebSocket error: $error');
        },
        onDone: () {
          state = ConnectionStatus.disconnected;
          _reconnect();
        },
      );

      state = ConnectionStatus.connected;
    } catch (e) {
      state = ConnectionStatus.error;
      logDebug('Failed to connect: $e');
    }
  }

  void _handleStreamData(dynamic data) {
    final json = jsonDecode(data as String);
    final type = json['type'] as String;
    final payload = json['payload'] as Map<String, dynamic>;

    switch (type) {
      case 'token':
        _handleTokenStream(payload);
        break;
      case 'tool_call':
        _handleToolCallStream(payload);
        break;
      case 'plan_update':
        _handlePlanUpdate(payload);
        break;
      case 'diff':
        _handleDiffStream(payload);
        break;
      case 'status':
        _handleStatusUpdate(payload);
        break;
      case 'error':
        _handleError(payload);
        break;
    }
  }

  void _handleTokenStream(Map<String, dynamic> payload) {
    final entryId = payload['entryId'] as String;
    final token = payload['token'] as String;
    final isComplete = payload['isComplete'] as bool? ?? false;

    // Update existing entry with streaming content
    _ref.read(chatTranscriptProvider(sessionId).notifier).appendToken(
          entryId,
          token,
          isComplete,
        );
  }

  void _handleToolCallStream(Map<String, dynamic> payload) {
    final toolCall = ToolCall.fromJson(payload['toolCall']);
    _ref.read(chatTranscriptProvider(sessionId).notifier).updateToolCall(
          toolCall.id,
          toolCall,
        );
  }

  void _handlePlanUpdate(Map<String, dynamic> payload) {
    final stepId = payload['stepId'] as String;
    final status = PlanStepStatus.values.firstWhere(
      (e) => e.toString() == payload['status'],
    );
    final planEntryId = payload['planEntryId'] as String;

    _ref.read(chatTranscriptProvider(sessionId).notifier).updatePlanStepStatus(
          planEntryId,
          stepId,
          status,
        );
  }

  void _handleDiffStream(Map<String, dynamic> payload) {
    // applyDiffUpdate not supported on FileDiffsNotifier — just log for now
    logDebug('Diff stream for ${payload['filePath']}');
  }

  void _handleStatusUpdate(Map<String, dynamic> payload) {
    final status = SessionStatus.values.firstWhere(
      (e) => e.toString() == payload['status'],
      orElse: () => SessionStatus.created,
    );
    _ref.read(sessionControllerProvider.notifier).updateStatus(status);
  }

  void _handleError(Map<String, dynamic> payload) {
    _ref.read(chatTranscriptProvider(sessionId).notifier).appendStep(
          '❌ ${payload['message']}',
        );
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (state != ConnectionStatus.connected) {
        _connect();
      }
    });
  }

  void sendMessage(String content, {Map<String, dynamic>? metadata}) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'message',
      'payload': {
        'content': content,
        'metadata': metadata ?? {},
      },
    }));
  }

  void cancelOperation(String operationId) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'cancel',
      'payload': {'operationId': operationId},
    }));
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}

final streamingProvider = StateNotifierProvider.family<
    StreamControllerNotifier,
    ConnectionStatus,
    String>((ref, sessionId) => StreamControllerNotifier(ref, sessionId));
