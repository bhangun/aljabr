import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

import '../providers/model_agent_providers.dart';

import 'package:aljabr_plugin_chat/src/composer/services/markdown_stream_buffer.dart';

import 'package:hive_flutter/hive_flutter.dart';

final chatTranscriptProvider = StateNotifierProvider.family<
    ChatTranscriptNotifier, List<ChatEntry>, String>(
  (ref, sessionId) => ChatTranscriptNotifier(ref, sessionId),
);

/// Registers the hook to clone transcript history when a session is forked.
void registerChatForkCloner() {
  sessionForkHistoryCloner = (ref, sourceId, targetId, [messageId]) {
    final parentEntries = ref.read(chatTranscriptProvider(sourceId));
    if (parentEntries.isNotEmpty) {
      List<ChatEntry> copiedEntries;
      if (messageId != null && messageId.isNotEmpty) {
        final idx = parentEntries.indexWhere((e) => e.id == messageId);
        if (idx != -1) {
          copiedEntries = parentEntries.sublist(0, idx + 1);
        } else {
          copiedEntries = List.from(parentEntries);
        }
      } else {
        copiedEntries = List.from(parentEntries);
      }
      ref
          .read(chatTranscriptProvider(targetId).notifier)
          .setEntries(copiedEntries);
    }
  };
}

/// The chat transcript, mixing plain agent text with structured [ToolCall]
/// rows and a blocking [ApprovalRequest] gate, the way Codex/Antigravity
/// interleave narration with actual tool execution.
///
/// Scoped per session (see [chatTranscriptProvider]'s `.family`) so forking
/// a session gives it its own independent transcript instead of sharing
/// the one the whole app used to point at.
class ChatTranscriptNotifier extends StateNotifier<List<ChatEntry>> {
  final Ref _ref;
  final String sessionId;
  static const String _kHiveBox = 'aljabr_chat_history';
  final List<ChatEntry> _pendingQueue = [];
  int _activeJobs = 0;
  static const int _maxConcurrentJobs = 3;

  // Streaming buffers per-entry id to throttle UI updates
  final Map<String, MarkdownStreamBuffer> _streamBuffers = {};

  ChatTranscriptNotifier(this._ref, this.sessionId) : super([]) {
    if (sessionId.isNotEmpty) {
      _loadFromHive();
      _loadHistory();
    }
  }

  void _loadFromHive() {
    try {
      final box = Hive.box(_kHiveBox);
      final raw = box.get(sessionId);
      if (raw != null) {
        final List<dynamic> list = raw is String ? jsonDecode(raw) : raw;
        final loaded = list.map((e) {
          try {
            return ChatEntry.fromJson(Map<String, dynamic>.from(e as Map));
          } catch (ex) {
            // Fallback for old data structure
            final m = Map<String, dynamic>.from(e as Map);
            return ChatEntry(
              id: m['id'] as String? ?? 'msg-1',
              type: ChatEntryType.values.firstWhere(
                (t) => t.name == (m['type'] as String? ?? ''),
                orElse: () => ChatEntryType.agentText,
              ),
              status: ChatEntryStatus.values.firstWhere(
                (s) => s.name == (m['status'] as String? ?? ''),
                orElse: () => ChatEntryStatus.completed,
              ),
              text: m['text'] as String? ?? '',
              timestamp: m['timestamp'] != null
                  ? DateTime.tryParse(m['timestamp'] as String) ??
                      DateTime.now()
                  : DateTime.now(),
              metadata: m['metadata'] != null
                  ? Map<String, dynamic>.from(m['metadata'] as Map)
                  : null,
            );
          }
        }).toList();
        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (e) {
      logDebug('Failed to load chat history from Hive for $sessionId: $e');
    }
  }

  void _saveToHive() {
    if (sessionId.isEmpty || sessionId == kGeneralSessionId) return;
    try {
      final box = Hive.box(_kHiveBox);
      final list = state.map((e) => e.toJson()).toList();
      box.put(sessionId, jsonEncode(list));
    } catch (e) {
      logDebug('Failed to save chat history to Hive: $e');
    }
  }

  void setEntries(List<ChatEntry> entries) {
    state = List.from(entries);
    _saveToHive();
  }

  Future<void> _loadHistory() async {
    if (sessionId.isEmpty || sessionId == kGeneralSessionId) return;
    try {
      final service = _ref.read(backendServiceProvider);
      final data = await service.listMessages(sessionId);
      if (data.isNotEmpty) {
        final entries = data
            .map((msg) => ChatEntry(
                  id: msg['id'] as String,
                  type: (msg['role'] as String? ?? '').toUpperCase() == 'USER'
                      ? ChatEntryType.userPrompt
                      : ChatEntryType.agentText,
                  text: msg['content'] as String? ?? '',
                  status: ChatEntryStatus.completed,
                  timestamp: DateTime.now(),
                ))
            .toList();
        if (mounted) {
          // Do not overwrite if local Hive state is richer (contains tool calls, etc.)
          if (state.length >= entries.length &&
              state.any((e) =>
                  e.type == ChatEntryType.toolCall ||
                  e.type == ChatEntryType.stepEvent)) {
            return;
          }
          state = entries;
          _saveToHive();
        }
      }
    } catch (e) {
      // code 12 = UNIMPLEMENTED, code 2 = UNKNOWN (backend down) — both are
      // non-critical: just show empty history without spamming the user.
      final msg = e.toString();
      if (!msg.contains('codeName: UNIMPLEMENTED') &&
          !msg.contains('code: 12') &&
          !msg.contains('code: 2')) {
        logDebug('Failed to load chat history: $e');
      }
    }
  }

  /// Start a streaming agent entry: creates a new processing entry with id
  /// and optional initial text. Tokens will be appended via [appendStreamingToken]
  void startStreamingEntry(String id, {String initial = ''}) {
    final entry = ChatEntry(
      id: id,
      type: ChatEntryType.agentText,
      text: initial,
      status: ChatEntryStatus.processing,
      timestamp: DateTime.now(),
    );
    appendEntry(entry);
  }

  void appendStreamingToken(String id, String token) {
    var buffer = _streamBuffers[id];
    if (buffer == null) {
      startStreamingEntry(id, initial: '');
      buffer = MarkdownStreamBuffer(
        flushDelay: const Duration(milliseconds: 100),
        onFlush: (text) {
          final idx = state.indexWhere((e) => e.id == id);
          if (idx >= 0) {
            final e = state[idx];
            appendEntry(e.copyWith(text: text));
          }
        },
      );
      _streamBuffers[id] = buffer;
    }
    buffer.append(token);
  }

  /// Finish a streaming entry, marking it completed.
  void finishStreamingEntry(String id) {
    final buffer = _streamBuffers.remove(id);
    if (buffer != null) {
      buffer.flush();
    }
    final idx = state.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final e = state[idx];
      appendEntry(e.copyWith(status: ChatEntryStatus.completed));
    }
  }

  /// Adds a user message with optional attachments
  Future<void> addUserMessage(String text,
      {List<Attachment>? attachments}) async {
    if (text.trim().isEmpty && (attachments == null || attachments.isEmpty)) {
      return;
    }

    final entry = ChatEntry(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      type: ChatEntryType.userPrompt,
      status: ChatEntryStatus.completed,
      text: text.trim(),
      isLoading: false,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    state = [...state, entry];
    _saveToHive();

    // Auto-rename session if it still has default title
    try {
      _ref
          .read(sessionListProvider.notifier)
          .autoRenameIfDefault(sessionId, text);
    } catch (_) {}

    // Queue the message for processing
    await _queueForProcessing(entry);
  }

  /// Appends a server-pushed event (see [AgentRepository]) if it isn't
  /// already present, or updates it if it exists — the stream can, in principle, replay, so this stays
  /// idempotent on entry id.
  void appendEntry(ChatEntry entry) {
    final idx = state.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == idx) entry else state[i],
      ];
    } else {
      state = [...state, entry];
    }
    _saveToHive();
  }

  /// Appends a lightweight step/status row (e.g. "Stopped by user").
  void appendStep(String text) {
    state = [
      ...state,
      ChatEntry(
        id: 'step-${DateTime.now().microsecondsSinceEpoch}',
        type: ChatEntryType.stepEvent,
        status: ChatEntryStatus.completed,
        timestamp: DateTime.now(),
        text: text,
      ),
    ];
  }

  /// Resolves a pending [ApprovalRequest] in place, then (if approved)
  /// appends the tool call it was gating.
  void resolveApproval(String approvalId, bool approved) {
    state = [
      for (final e in state)
        if (e.type == ChatEntryType.approvalRequest &&
            e.approval?.id == approvalId)
          e.copyWith(
            approval: e.approval!.copyWith(
              status:
                  approved ? ApprovalStatus.approved : ApprovalStatus.denied,
            ),
          )
        else
          e,
    ];

    if (approved) {
      state = [
        ...state,
        ChatEntry(
          id: 'tc-post-approval-${DateTime.now().microsecondsSinceEpoch}',
          type: ChatEntryType.toolCall,
          toolCall: const ToolCall(
            id: 'tc-push',
            kind: ToolCallKind.runCommand,
            summary: 'git push origin main',
            detailInput: 'git push origin main',
            detailOutput:
                'Enumerating objects... done.\nTo github.com:wayang-platform/wayang-code.git\n   4f2a1c9..9b7e0d1  main -> main',
            status: ToolCallStatus.success,
            duration: Duration(seconds: 3),
          ),
          status: ChatEntryStatus.completed,
          timestamp: DateTime.now(),
        ),
      ];
    } else {
      appendStep('Push denied — the agent will wait for further instructions.');
    }
  }

  /// Updates a single step's status within a [ChatEntryType.plan] entry —
  /// how the plan checklist stays in sync with what the agent has actually
  /// finished, rather than being a static list printed once.
  void updatePlanStepStatus(
      String planEntryId, String stepId, PlanStepStatus status) {
    state = [
      for (final e in state)
        if (e.id == planEntryId && e.plan != null)
          e.copyWith(
            plan: e.plan!.copyWith(
              steps: [
                for (final s in e.plan!.steps)
                  if (s.id == stepId) s.copyWith(status: status) else s,
              ],
            ),
          )
        else
          e,
    ];
  }

  /// Truncates the transcript back to [cutoff] entries and appends a note —
  /// used when the user restores a [Checkpoint].
  void restoreToCheckpoint(int cutoff, String label) {
    final kept = state.take(cutoff).toList();
    state = [
      ...kept,
      ChatEntry(
        id: 'restore-${DateTime.now().microsecondsSinceEpoch}',
        type: ChatEntryType.stepEvent,
        status: ChatEntryStatus.completed,
        timestamp: DateTime.now(),
        text:
            'Restored to checkpoint "$label" — later messages and file changes were discarded.',
      ),
    ];
  }

  /// Queue an entry for processing by the agent
  Future<void> _queueForProcessing(ChatEntry entry) async {
    try {
      final service = _ref.read(backendServiceProvider);

      // Check if we can process immediately
      if (_activeJobs < _maxConcurrentJobs) {
        _activeJobs++;
        await _processEntry(entry, service);
        _activeJobs--;
        _processNextInQueue();
      } else {
        // Add to queue
        _pendingQueue.add(entry);
        _updateQueueStatus();
      }
    } catch (e) {
      logDebug('Failed to queue message: $e');
      _handleEntryError(entry, e.toString());
    }
  }

  /// Process an entry through the ReAct streaming loop.
  Future<void> _processEntry(ChatEntry entry, dynamic service) async {
    _updateEntryStatus(entry.id, ChatEntryStatus.processing);

    try {
      final selectedProvider = _ref.read(selectedProviderProvider);
      final selectedModel = _ref.read(selectedModelProvider);
      final project = _ref.read(activeProjectProvider);

      final resolvedProvider =
          selectedProvider.isEmpty ? 'gollek' : selectedProvider;
      final resolvedModel = selectedModel.isEmpty
          ? 'hf:unsloth/gemma-4-12b-it-gguf'
          : selectedModel;
      final resolvedSession = sessionId.isEmpty ? 'default-session' : sessionId;
      final workspacePath = project?.rootPath ?? '';

      // Prepare conversation context
      final buffer = StringBuffer();
      final contextEntries = state
          .where((e) =>
              e.type == ChatEntryType.userPrompt ||
              e.type == ChatEntryType.agentText ||
              e.type == ChatEntryType.toolCall ||
              e.type == ChatEntryType.stepEvent)
          .takeWhile((e) => e.id != entry.id)
          .toList();

      // Keep last 10 messages to prevent context overflow
      final int skipCount =
          contextEntries.length > 10 ? contextEntries.length - 10 : 0;
      final recentEntries = contextEntries.skip(skipCount).toList();

      if (recentEntries.isNotEmpty) {
        buffer.writeln("=== CONVERSATION HISTORY ===");
        for (final e in recentEntries) {
          if (e.type == ChatEntryType.userPrompt) {
            buffer.writeln("USER: ${e.text}");
          } else if (e.type == ChatEntryType.agentText) {
            // Truncate overly long AI responses (e.g. massive code blocks) to keep context safe
            final text = e.text.length > 800
                ? '${e.text.substring(0, 800)}... (truncated)'
                : e.text;
            buffer.writeln("ASSISTANT: $text");
          } else if (e.type == ChatEntryType.toolCall) {
            buffer.writeln(
                "ASSISTANT CALLED TOOL: ${e.toolCall?.summary} (Input: ${e.toolCall?.detailInput})");
          } else if (e.type == ChatEntryType.stepEvent) {
            // Tool results can be massive (e.g. tree/list directory). Strictly truncate them.
            final text = e.text.length > 500
                ? '${e.text.substring(0, 500)}... (truncated)'
                : e.text;
            buffer.writeln("SYSTEM/TOOL RESULT: $text");
          }
        }
        buffer.writeln("=== END HISTORY ===\n");
      }

      buffer.writeln("CURRENT USER REQUEST:");
      buffer.writeln(entry.text);

      logInfo(
          'CHAT: calling runAgent provider=$resolvedProvider model=$resolvedModel session=$resolvedSession');

      final stream = service.runAgent(
        sessionId: resolvedSession,
        prompt: buffer.toString(),
        providerId: resolvedProvider,
        modelId: resolvedModel,
        workspacePath: workspacePath,
      );

      // Prefix for all entries emitted during this response turn.
      final responseIdPrefix = 'agent-${entry.id}';

      // Channel text buffers: 'thinking', 'response', etc.
      final channelBuffers = <String, StringBuffer>{};
      final sharedMetadata = <String, dynamic>{
        'renderMarkdown': true,
        'supports': ['tables', 'codeblocks', 'mermaid', 'latex', 'diff'],
      };

      // Immediately show an "agent is working" indicator so the user
      // doesn't stare at a blank screen while the model loads/reasons.
      // Use a unique "bootstrap" id so it doesn't clash with the stream's
      // own thinking-channel entry.
      final bootstrapId = '$responseIdPrefix-bootstrap';
      appendEntry(ChatEntry(
        id: bootstrapId,
        type: ChatEntryType.thinking,
        status: ChatEntryStatus.processing,
        text: 'Working…',
        timestamp: DateTime.now(),
        metadata: sharedMetadata,
      ));
      bool bootstrapDismissed = false;
      int lastTokenUpdateMs = 0;

      // Helper: remove the bootstrap card once real content starts arriving.
      void dismissBootstrap() {
        if (!bootstrapDismissed) {
          bootstrapDismissed = true;
          state = [
            for (final e in state)
              if (e.id != bootstrapId) e
          ];
        }
      }

      await for (final result in stream) {
        // ── Backend error ──────────────────────────────────────────────────
        if (result.containsKey('error')) {
          dismissBootstrap();
          final error = result['error'] as String? ?? 'Unknown error';
          logDebug('CHAT BACKEND ERROR: $error');
          appendEntry(ChatEntry(
            id: '$responseIdPrefix-error',
            type: ChatEntryType.systemMessage,
            status: ChatEntryStatus.failed,
            text: error,
            timestamp: DateTime.now(),
          ));
          _updateEntryStatus(entry.id, ChatEntryStatus.failed);
          return;
        }

        // ── Tool call event ────────────────────────────────────────────────
        if (result.containsKey('tool_call')) {
          dismissBootstrap();
          final rawToolText = result['tool_call'] as String? ?? 'tool';
          // Extract clean tool name if formatted like "> 📁 **list_directory** ..."
          var cleanName = rawToolText;
          final boldMatch =
              RegExp(r'\*\*([a-zA-Z0-9_\-\.]+)\*\*').firstMatch(rawToolText);
          if (boldMatch != null) {
            cleanName = boldMatch.group(1)!;
          } else {
            cleanName = rawToolText
                .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), ' ')
                .trim()
                .split(' ')
                .first;
          }
          if (cleanName.isEmpty) cleanName = 'tool';

          final toolId =
              '$responseIdPrefix-tool-$cleanName-${DateTime.now().millisecondsSinceEpoch}';

          String? detailInput;
          try {
            final payloadStr = result['payload']?.toString();
            if (payloadStr != null &&
                payloadStr.isNotEmpty &&
                payloadStr != '{}') {
              final payloadJson =
                  jsonDecode(payloadStr) as Map<String, dynamic>;
              final argsStr = payloadJson['data']?.toString() ??
                  payloadJson['arguments']?.toString() ??
                  '{}';
              try {
                final parsedArgs = jsonDecode(argsStr);
                detailInput =
                    const JsonEncoder.withIndent('  ').convert(parsedArgs);
              } catch (_) {
                detailInput = argsStr;
              }
            }
          } catch (_) {
            detailInput = null;
          }

          final kind = ToolCallKindX.fromString(cleanName);

          appendEntry(ChatEntry(
            id: toolId,
            type: ChatEntryType.toolCall,
            status: ChatEntryStatus.processing,
            text: rawToolText,
            timestamp: DateTime.now(),
            toolCall: ToolCall(
              id: toolId,
              kind: kind,
              summary: rawToolText.startsWith('>')
                  ? rawToolText
                      .replaceAll(RegExp(r'^[>\s\📁\📄\🔍\🌿\🔨]+'), '')
                      .trim()
                  : cleanName,
              detailInput: detailInput != null && detailInput.trim().isNotEmpty
                  ? detailInput
                  : null,
              status: ToolCallStatus.running,
            ),
          ));
          continue;
        }

        // ── Tool result event ──────────────────────────────────────────────
        if (result.containsKey('tool_result')) {
          final resultText = result['tool_result'] as String? ?? '';

          String? detailOutput;
          try {
            final payloadStr = result['payload']?.toString();
            if (payloadStr != null &&
                payloadStr.isNotEmpty &&
                payloadStr != '{}') {
              final payloadJson =
                  jsonDecode(payloadStr) as Map<String, dynamic>;
              detailOutput = payloadJson['data']?.toString() ?? payloadStr;
            }
          } catch (_) {
            detailOutput = resultText.isNotEmpty ? resultText : null;
          }
          if (detailOutput == null && resultText.isNotEmpty) {
            detailOutput = resultText;
          }

          state = [
            for (final e in state)
              if (e.type == ChatEntryType.toolCall &&
                  e.status == ChatEntryStatus.processing)
                e.copyWith(
                  status: ChatEntryStatus.completed,
                  text: resultText.isNotEmpty ? resultText : e.text,
                  toolCall: e.toolCall?.copyWith(
                    status: ToolCallStatus.success,
                    detailOutput:
                        detailOutput != null && detailOutput.trim().isNotEmpty
                            ? detailOutput
                            : null,
                  ),
                )
              else
                e,
          ];
          continue;
        }

        // ── DONE event ─────────────────────────────────────────────────────
        if (result.containsKey('status')) {
          final statusStr = result['status'] as String? ?? '';
          final sessionStatus = SessionStatus.values.firstWhere(
            (s) => s.toString() == statusStr,
            orElse: () => SessionStatus.created,
          );
          _updateSessionStatus(sessionStatus);
          break;
        }

        // ── Text/thinking stream ───────────────────────────────────────────
        // THOUGHT events from gRPC arrive as {'channel': 'thinking', 'content': '...'}
        // TEXT events arrive as {'content': '...'} (no channel key)
        final rawContent = result['content'] as String? ?? '';
        if (rawContent.isEmpty) continue;
        dismissBootstrap();

        try {
          // First check top-level 'channel' key (set by THOUGHT events in grpc_backend_service.dart)
          var channel = result.containsKey('channel')
              ? (result['channel'] as String? ?? 'response')
              : 'response';
          var text = rawContent;

          // Also try JSON envelope: {"t": "response", "d": "..."} (from ChatGrpcService)
          if (channel == 'response' && rawContent.startsWith('{')) {
            try {
              final decoded = jsonDecode(rawContent) as Map<String, dynamic>;
              if (decoded.containsKey('t')) {
                channel = decoded['t'] as String;
              } else if (decoded.containsKey('channel')) {
                channel = decoded['channel'] as String;
              }
              if (decoded.containsKey('d')) {
                text = decoded['d'] as String;
              } else if (decoded.containsKey('text')) {
                text = decoded['text'] as String;
              }
            } catch (_) {
              // Not valid JSON, keep as raw text on 'response' channel
            }
          }
          if (channel == 'metrics') {
            try {
              sharedMetadata['metrics_raw'] = text;
              sharedMetadata['metrics'] = jsonDecode(text);
              // Parsed metrics stored in sharedMetadata
            } catch (_) {}

            // Update the existing response entry if it exists to attach the new metadata
            if (channelBuffers.containsKey('response')) {
              appendEntry(ChatEntry(
                id: '$responseIdPrefix-response',
                type: ChatEntryType.agentText,
                status: ChatEntryStatus.processing,
                text: channelBuffers['response']!.toString(),
                timestamp: DateTime.now(),
                metadata: sharedMetadata,
              ));
            }
            continue;
          }

          channelBuffers.putIfAbsent(channel, StringBuffer.new);
          channelBuffers[channel]!.write(text);

          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastTokenUpdateMs > 60) {
            lastTokenUpdateMs = now;
            appendEntry(ChatEntry(
              id: '$responseIdPrefix-$channel',
              type: channel == 'thinking'
                  ? ChatEntryType.thinking
                  : ChatEntryType.agentText,
              status: ChatEntryStatus.processing,
              text: channelBuffers[channel]!.toString(),
              timestamp: DateTime.now(),
              metadata: sharedMetadata,
            ));
          }
        } catch (_) {
          channelBuffers.putIfAbsent('response', StringBuffer.new);
          channelBuffers['response']!.write(rawContent);

          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastTokenUpdateMs > 60) {
            lastTokenUpdateMs = now;
            appendEntry(ChatEntry(
              id: '$responseIdPrefix-response',
              type: ChatEntryType.agentText,
              status: ChatEntryStatus.processing,
              text: channelBuffers['response']!.toString(),
              timestamp: DateTime.now(),
              metadata: sharedMetadata,
            ));
          }
        }
      }

      // Always perform a final flush of all channels with their full content
      for (final ch in channelBuffers.keys) {
        appendEntry(ChatEntry(
          id: '$responseIdPrefix-$ch',
          type: ch == 'thinking'
              ? ChatEntryType.thinking
              : ChatEntryType.agentText,
          status: ChatEntryStatus.completed,
          text: channelBuffers[ch]!.toString(),
          timestamp: DateTime.now(),
          metadata: sharedMetadata,
        ));
      }

      // Post-stream cleanup: remove bootstrap "Working…" card if it was never dismissed
      // (e.g. stream ended without emitting any events at all).
      dismissBootstrap();

      // Post-stream: if only thinking arrived, reclassify it as the answer
      final hasResponse = channelBuffers.containsKey('response') &&
          channelBuffers['response']!.isNotEmpty;
      final hasThinking = channelBuffers.containsKey('thinking') &&
          channelBuffers['thinking']!.isNotEmpty;

      if (hasThinking && !hasResponse) {
        state = [
          for (final e in state)
            if (e.id == '$responseIdPrefix-thinking')
              e.copyWith(
                  type: ChatEntryType.agentText,
                  status: ChatEntryStatus.completed)
            else
              e,
        ];
      } else {
        for (final channel in channelBuffers.keys) {
          _updateEntryStatus(
              '$responseIdPrefix-$channel', ChatEntryStatus.completed);
        }
      }

      // If stream produced no TEXT at all, emit a fallback so the user
      // always sees *something* rather than a blank turn.
      if (!hasResponse && !hasThinking) {
        appendEntry(ChatEntry(
          id: '$responseIdPrefix-response',
          type: ChatEntryType.agentText,
          status: ChatEntryStatus.completed,
          text:
              '_The agent finished processing but produced no text response. You can try rephrasing your request._',
          timestamp: DateTime.now(),
          metadata: sharedMetadata,
        ));
      }

      _updateEntryStatus(entry.id, ChatEntryStatus.completed);
    } catch (e, st) {
      logDebug('CHAT ERROR: $e\n$st');
      _handleEntryError(entry, e.toString());
    }
  }

  /// Process the next entry in the queue
  void _processNextInQueue() {
    if (_pendingQueue.isEmpty || _activeJobs >= _maxConcurrentJobs) return;

    final next = _pendingQueue.removeAt(0);
    _activeJobs++;
    _updateQueueStatus();

    final service = _ref.read(backendServiceProvider);
    _processEntry(next, service).then((_) {
      _activeJobs--;
      _processNextInQueue();
    });
  }

  /// Update queue status in the UI
  void _updateQueueStatus() {
    final pendingCount = _pendingQueue.length;
    // Notify session of pending count to show badge in sidebar
    final activeId = _ref.read(activeSessionIdProvider);
    final sessionList = _ref.read(sessionListProvider.notifier);
    final sessions = _ref.read(sessionListProvider);
    final session = sessions.where((s) => s.id == activeId).firstOrNull;
    if (session != null) {
      sessionList.updateSession(
          activeId, session.copyWith(pendingCount: pendingCount));
    }
  }

  /// Force process all pending entries
  Future<void> forceProcessAll() async {
    if (_pendingQueue.isEmpty) return;

    final entriesToProcess = List<ChatEntry>.from(_pendingQueue);
    _pendingQueue.clear();
    _updateQueueStatus();

    // Process up to max concurrent
    final chunks = _chunkList(entriesToProcess, _maxConcurrentJobs);
    for (final chunk in chunks) {
      await Future.wait(chunk.map((e) => _queueForProcessing(e)));
    }
  }

  /// Force process a single pending entry
  Future<void> forceProcessSingle(String entryId) async {
    final index = _pendingQueue.indexWhere((e) => e.id == entryId);
    if (index == -1) return;

    final entry = _pendingQueue.removeAt(index);
    _updateQueueStatus();
    await _queueForProcessing(entry);
  }

  /// Append a streaming token to an existing entry (used by WebSocket stream)
  void appendToken(String entryId, String token, bool isComplete) {
    // Use per-entry MarkdownStreamBuffer to batch frequent token events.
    final buffer = _streamBuffers.putIfAbsent(
      entryId,
      () => MarkdownStreamBuffer(
        flushDelay: const Duration(milliseconds: 80),
        onFlush: (text) {
          final existing = state.firstWhere(
            (e) => e.id == entryId,
            orElse: () => ChatEntry(
              id: entryId,
              type: ChatEntryType.agentText,
              status: ChatEntryStatus.processing,
              text: '',
              timestamp: DateTime.now(),
            ),
          );
          final updated = existing.copyWith(
            text: text,
            status: isComplete
                ? ChatEntryStatus.completed
                : ChatEntryStatus.processing,
          );
          if (state.any((e) => e.id == entryId)) {
            state = [
              for (final e in state)
                if (e.id == entryId) updated else e
            ];
          } else {
            state = [...state, updated];
          }
          if (isComplete) {
            // Clean up buffer after final flush
            _streamBuffers.remove(entryId);
          }
        },
      ),
    );

    buffer.append(token);
    if (isComplete) buffer.flush();
  }

  /// Update an existing tool call entry (used by WebSocket stream)
  void updateToolCall(String toolCallId, ToolCall toolCall) {
    state = [
      for (final e in state)
        if (e.toolCall?.id == toolCallId) e.copyWith(toolCall: toolCall) else e,
    ];
  }

  void _updateEntryStatus(String entryId, ChatEntryStatus status) {
    state = [
      for (final e in state)
        if (e.id == entryId) e.copyWith(status: status) else e,
    ];
  }

  void _handleEntryError(ChatEntry entry, String error) {
    state = [
      for (final e in state)
        if (e.id == entry.id)
          e.copyWith(
            status: ChatEntryStatus.failed,
            errorMessage: error,
          )
        else
          e,
    ];

    // Add error message to transcript
    state = [
      ...state,
      ChatEntry(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        type: ChatEntryType.systemMessage,
        status: ChatEntryStatus.completed,
        text: '❌ Error: $error',
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Update the status of the current session
  void _updateSessionStatus(SessionStatus status) {
    final activeId = _ref.read(activeSessionIdProvider);
    final sessionList = _ref.read(sessionListProvider.notifier);
    final sessions = _ref.read(sessionListProvider);
    final session = sessions.where((s) => s.id == activeId).firstOrNull;
    if (session != null) {
      sessionList.updateSession(activeId, session.copyWith(status: status));
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  /// Toggle session mode between auto/manual/hybrid
  void toggleSessionMode(SessionMode mode) {
    final activeId = _ref.read(activeSessionIdProvider);
    final sessionList = _ref.read(sessionListProvider.notifier);
    final sessions = _ref.read(sessionListProvider);
    final session = sessions.where((s) => s.id == activeId).firstOrNull;
    if (session != null) {
      sessionList.updateSession(activeId, session.copyWith(mode: mode));
    }
  }

  /// Get pending entries count
  int get pendingCount => _pendingQueue.length;

  /// Get current queue size
  int get queueSize =>
      _pendingQueue.length +
      state.where((e) => e.status == ChatEntryStatus.processing).length;

  /// Get a copy of the pending queue for forking
  List<ChatEntry> get pendingEntries => List.unmodifiable(_pendingQueue);

  /// Restore pending queue after forking
  void restorePendingQueue(List<ChatEntry> queue) {
    _pendingQueue.addAll(queue);
    _updateQueueStatus();
  }

  /// Alias for toggleSessionMode used by session actions
  void setSessionMode(SessionMode mode) => toggleSessionMode(mode);

  /// Cancel all pending tasks
  void cancelPendingAll() {
    _pendingQueue.clear();
    _updateQueueStatus();
  }

  /// Toggle pause/resume for processing
  void togglePause() {
    // Basic pause stub, queue processing stops picking up tasks when paused
    // Full pause state handling would be added here
  }
}
