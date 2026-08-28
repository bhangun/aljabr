import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wayang_code/core/utils/line_level_diff_engine.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/entities/app_settings.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/language_detector.dart';
import '../../../presentation/providers/infrastructure_providers.dart';
import '../models/branch.dart';
import '../models/file_diff.dart';
import '../models/file_reference.dart';
import '../models/message.dart';
import '../models/session.dart';
import 'sessions_provider.dart';
import '../../settings/states/settings_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ChatState {
  const ChatState({
    this.session,
    this.isLoading = false,
    this.error,
    this.activeFiles = const [],
    this.selectedDiff,
    this.editingMessageId,
  });

  final Session? session;
  final bool isLoading;
  final String? error;
  final List<FileReference> activeFiles;
  final FileDiff? selectedDiff;
  final String? editingMessageId;

  List<Message> get messages => session?.messages ?? [];

  /// Rough token estimate of everything that would be sent on the next turn:
  /// all messages plus all active file contents plus the system prompt.
  int estimateContextTokens(String systemPrompt) {
    var total = AppConstants.estimateTokens(systemPrompt);
    for (final m in messages) {
      total += AppConstants.estimateTokens(m.content);
    }
    for (final f in activeFiles) {
      total += AppConstants.estimateTokens(f.content);
    }
    return total;
  }

  ChatState copyWith({
    Session? session,
    bool? isLoading,
    String? error,
    List<FileReference>? activeFiles,
    FileDiff? selectedDiff,
    bool clearDiff = false,
    bool clearError = false,
    String? editingMessageId,
    bool clearEditing = false,
  }) => ChatState(
    session: session ?? this.session,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activeFiles: activeFiles ?? this.activeFiles,
    selectedDiff: clearDiff ? null : (selectedDiff ?? this.selectedDiff),
    editingMessageId: clearEditing
        ? null
        : (editingMessageId ?? this.editingMessageId),
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._ref) : super(const ChatState());

  final Ref _ref;
  StreamSubscription<dynamic>? _streamSub;

  AppSettings get _settings => _ref.read(settingsProvider);

  // ── Session management ────────────────────────────────────────────────────

  Future<void> loadSession(Session session) async {
    _cancelStream();
    state = ChatState(session: session, activeFiles: List.of(session.files), isLoading: true);
    if (session.projectId != null) {
      final result = await _ref.read(sessionRepositoryProvider).getSessionTranscript(session.id, session.projectId!);
      result.fold(
        onSuccess: (messages) {
          final updated = session.copyWith(messages: messages);
          if (mounted && state.session?.id == session.id) {
             state = ChatState(session: updated, activeFiles: List.of(updated.files), isLoading: false);
          }
        },
        onFailure: (e) {
          if (mounted && state.session?.id == session.id) {
             state = state.copyWith(isLoading: false, error: e.message);
          }
        },
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearSession() {
    _cancelStream();
    state = const ChatState();
  }

  // ── File management ───────────────────────────────────────────────────────

  void addFile(FileReference file) {
    if (state.activeFiles.any((f) => f.id == file.id)) return;
    final files = [...state.activeFiles, file];
    state = state.copyWith(activeFiles: files);
    _persistFiles(files);
  }

  void removeFile(String fileId) {
    final files = state.activeFiles.where((f) => f.id != fileId).toList();
    state = state.copyWith(activeFiles: files);
    _persistFiles(files);
  }

  void updateFileContent(String fileId, String newContent) {
    final files = state.activeFiles
        .map((f) => f.id == fileId ? f.copyWith(content: newContent) : f)
        .toList();
    state = state.copyWith(activeFiles: files);
    _persistFiles(files);
  }

  FileReference createFileFromInput({
    required String name,
    required String content,
    String? path,
  }) {
    final lang = LanguageDetector.fromFileName(name);
    return FileReference(
      id: generateId(),
      name: name,
      path: path ?? name,
      content: content,
      language: lang,
    );
  }

  // ── Diff management ───────────────────────────────────────────────────────

  void selectDiff(FileDiff diff) => state = state.copyWith(selectedDiff: diff);
  void clearDiff() => state = state.copyWith(clearDiff: true);

  void applyDiff(FileDiff diff) {
    updateFileContent(diff.fileId, diff.modifiedContent);
    state = state.copyWith(clearDiff: true);
  }

  void rejectDiff(FileDiff diff) {
    state = state.copyWith(clearDiff: true);
  }

  void applyAllDiffs(List<FileDiff> diffs) {
    var files = state.activeFiles;
    for (final d in diffs) {
      files = files
          .map(
            (f) =>
                f.id == d.fileId ? f.copyWith(content: d.modifiedContent) : f,
          )
          .toList();
    }
    state = state.copyWith(activeFiles: files, clearDiff: true);
    _persistFiles(files);
  }

  // ── Cancellation ──────────────────────────────────────────────────────────

  void cancelStreaming() {
    _cancelStream();
    final session = state.session;
    if (session == null) return;
    // Mark the in-flight assistant message as stopped, keep partial content.
    final msgs = session.messages.map((m) {
      if (m.isStreaming) {
        return m.copyWith(
          isStreaming: false,
          content: m.content.isEmpty
              ? '_Cancelled._'
              : '${m.content}\n\n_[stopped]_',
        );
      }
      return m;
    }).toList();
    final updated = session.copyWith(messages: msgs);
    state = state.copyWith(session: updated, isLoading: false);
    _persistSession(updated);
  }

  void _cancelStream() {
    _streamSub?.cancel();
    _streamSub = null;
  }

  // ── Messaging ─────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (state.session == null) {
      await _createAndLoadSession(text);
    }

    final session = state.session!;
    final userMessage = Message(
      id: generateId(),
      role: MessageRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
      attachedFiles: List.of(state.activeFiles),
      tokenCount: AppConstants.estimateTokens(text),
    );

    final withUser = _appendMessage(session, userMessage);
    state = state.copyWith(
      session: withUser,
      isLoading: true,
      clearError: true,
    );
    await _persistSession(withUser);

    await _dispatchAssistantTurn(withUser);
  }

  /// Re-sends the conversation truncated at [messageId] (the user message
  /// being edited) with [newText] replacing its content, discarding every
  /// turn that came after it.
  Future<void> editAndResend(String messageId, String newText) async {
    final session = state.session;
    if (session == null || newText.trim().isEmpty) return;

    final idx = session.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final editedMsg = session.messages[idx].copyWith(
      content: newText.trim(),
      wasEdited: true,
    );
    final truncated = session.messages.take(idx).toList()..add(editedMsg);
    final updatedSession = session.copyWith(messages: truncated);

    state = state.copyWith(
      session: updatedSession,
      isLoading: true,
      clearError: true,
      clearEditing: true,
    );
    await _persistSession(updatedSession);

    await _dispatchAssistantTurn(updatedSession);
  }

  void beginEditingMessage(String messageId) =>
      state = state.copyWith(editingMessageId: messageId);
  void cancelEditingMessage() => state = state.copyWith(clearEditing: true);

  Future<void> retryLastMessage() async {
    final session = state.session;
    if (session == null || session.messages.isEmpty) return;

    final msgs = session.messages.toList();
    while (msgs.isNotEmpty && msgs.last.role == MessageRole.assistant) {
      msgs.removeLast();
    }
    final lastUser = msgs.isEmpty ? null : msgs.last;
    if (lastUser == null || lastUser.role != MessageRole.user) return;

    final trimmed = session.copyWith(messages: msgs);
    state = state.copyWith(session: trimmed, isLoading: true, clearError: true);
    await _persistSession(trimmed);
    await _dispatchAssistantTurn(trimmed);
  }

  /// Regenerates a specific assistant message in place (keeps its position,
  /// re-runs the model using everything before it as context).
  Future<void> regenerateMessage(String assistantMessageId) async {
    final session = state.session;
    if (session == null) return;
    final idx = session.messages.indexWhere((m) => m.id == assistantMessageId);
    if (idx <= 0) return;

    final truncated = session.messages.take(idx).toList();
    final updatedSession = session.copyWith(messages: truncated);
    state = state.copyWith(
      session: updatedSession,
      isLoading: true,
      clearError: true,
    );
    await _persistSession(updatedSession);
    await _dispatchAssistantTurn(updatedSession);
  }

  Future<void> _dispatchAssistantTurn(Session session) async {
    final assistantId = generateId();
    final placeholder = Message(
      id: assistantId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    final withPlaceholder = _appendMessage(session, placeholder);
    state = state.copyWith(session: withPlaceholder);

    final settings = _settings;
    if (settings.provider == AiProvider.claude && !settings.hasApiKey) {
      _setAssistantError(
        assistantId,
        'No API key set. Go to Settings to add your Anthropic API key.',
      );
      return;
    }

    if (settings.streamingEnabled) {
      await _streamResponse(assistantId, withPlaceholder, settings);
    } else {
      await _completeResponse(assistantId, withPlaceholder, settings);
    }
  }

  Future<void> _streamResponse(
    String assistantId,
    Session session,
    AppSettings settings,
  ) async {
    final buffer = StringBuffer();
    final completer = Completer<void>();

    if (settings.provider == AiProvider.wayangPro) {
      final stream = _ref
          .read(wayangProApiDatasourceProvider)
          .streamCompletion(
            baseUrl: settings.wayangProBaseUrl,
            model: settings.model,
            messages: session.messages,
            maxTokens: settings.maxTokens,
            systemPrompt: settings.systemPrompt,
            providerId: 'gollek',
          );

      _streamSub = stream.listen(
        (result) {
          result.fold(
            onSuccess: (delta) {
              buffer.write(delta);
              _updateStreamingMessage(assistantId, buffer.toString());
            },
            onFailure: (error) {
              _setAssistantError(assistantId, error.message);
            },
          );
        },
        onDone: () {
          _finalizeAssistant(assistantId, buffer.toString());
          if (!completer.isCompleted) completer.complete();
        },
        onError: (e) {
          _setAssistantError(assistantId, e.toString());
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: true,
      );
    } else {
      final stream = _ref
          .read(claudeApiDatasourceProvider)
          .streamCompletion(
            apiKey: settings.apiKey,
            model: settings.model,
            messages: session.messages,
            maxTokens: settings.maxTokens,
            systemPrompt: settings.systemPrompt,
          );

      _streamSub = stream.listen(
        (result) {
          result.fold(
            onSuccess: (delta) {
              buffer.write(delta);
              _updateStreamingMessage(assistantId, buffer.toString());
            },
            onFailure: (error) {
              _setAssistantError(assistantId, error.message);
            },
          );
        },
        onDone: () {
          _finalizeAssistant(assistantId, buffer.toString());
          if (!completer.isCompleted) completer.complete();
        },
        onError: (e) {
          _setAssistantError(assistantId, e.toString());
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: true,
      );
    }

    await completer.future;
    _streamSub = null;
  }

  Future<void> _completeResponse(
    String assistantId,
    Session session,
    AppSettings settings,
  ) async {
    if (settings.provider == AiProvider.wayangPro) {
      final result = await _ref
          .read(wayangProApiDatasourceProvider)
          .complete(
            baseUrl: settings.wayangProBaseUrl,
            model: settings.model,
            messages: session.messages
                .where((m) => m.role != MessageRole.system)
                .toList(),
            maxTokens: settings.maxTokens,
            systemPrompt: settings.systemPrompt,
            providerId: 'gollek',
          );

      result.fold(
        onSuccess: (text) => _finalizeAssistant(assistantId, text),
        onFailure: (error) => _setAssistantError(assistantId, error.message),
      );
    } else {
      final result = await _ref
          .read(claudeApiDatasourceProvider)
          .complete(
            apiKey: settings.apiKey,
            model: settings.model,
            messages: session.messages
                .where((m) => m.role != MessageRole.system)
                .toList(),
            maxTokens: settings.maxTokens,
            systemPrompt: settings.systemPrompt,
          );

      result.fold(
        onSuccess: (text) => _finalizeAssistant(assistantId, text),
        onFailure: (error) => _setAssistantError(assistantId, error.message),
      );
    }
  }
  // ── Internal helpers ──────────────────────────────────────────────────────

  void _updateStreamingMessage(String id, String content) {
    if (!mounted) return;
    final session = state.session;
    if (session == null) return;
    final msgs = session.messages
        .map((m) => m.id == id ? m.copyWith(content: content) : m)
        .toList();
    state = state.copyWith(session: session.copyWith(messages: msgs));
  }

  void _finalizeAssistant(String id, String content) {
    if (!mounted) return;
    final session = state.session;
    if (session == null) return;

    final diffs = LineDiffEngine.extractDiffsFromResponse(
      responseText: content,
      contextFiles: state.activeFiles,
    );

    final finalMsg = session.messages
        .firstWhere((m) => m.id == id)
        .copyWith(
          content: content,
          isStreaming: false,
          diffs: diffs,
          tokenCount: AppConstants.estimateTokens(content),
        );

    final msgs = session.messages
        .map((m) => m.id == id ? finalMsg : m)
        .toList();
    final updatedSession = session.copyWith(messages: msgs);
    state = state.copyWith(session: updatedSession, isLoading: false);
    _persistSession(updatedSession);
  }

  void _setAssistantError(String id, String errorMsg) {
    if (!mounted) return;
    final session = state.session;
    if (session == null) return;

    final msgs = session.messages
        .map(
          (m) => m.id == id
              ? m.copyWith(
                  content: errorMsg,
                  isStreaming: false,
                  hasError: true,
                  errorMessage: errorMsg,
                )
              : m,
        )
        .toList();
    final updated = session.copyWith(messages: msgs);
    state = state.copyWith(session: updated, isLoading: false, error: errorMsg);
    _persistSession(updated);
  }

  Session _appendMessage(Session session, Message message) =>
      session.copyWith(messages: [...session.messages, message]);

  Future<void> _createAndLoadSession(String firstMessage) async {
    final title = firstMessage.truncate(50);
    final session = await _ref
        .read(sessionsProvider.notifier)
        .createSession(title: title);
    state = state.copyWith(session: session);
  }

  Future<void> _persistSession(Session session) async {
    await _ref.read(sessionRepositoryProvider).updateSession(session);
    if (session.projectId != null) {
      await _ref.read(sessionRepositoryProvider).saveSessionTranscript(session.id, session.projectId!, session.messages);
    }
    _ref.read(sessionsProvider.notifier).updateSessionInList(session);
  }

  Future<void> _persistFiles(List<FileReference> files) async {
    final session = state.session;
    if (session == null) return;
    final updated = session.copyWith(files: files);
    state = state.copyWith(session: updated);
    await _persistSession(updated);
  }

  /// Branching helpers
  void switchBranch(String branchId) {
    final session = state.session;
    if (session == null || session is! BranchingSession) return;
    final bs = session as BranchingSession;
    if (!bs.branches.any((b) => b.id == branchId)) return;
    final updated = bs.copyWith(currentBranchId: branchId);
    state = state.copyWith(session: updated);
    _persistSession(updated);
  }

  void deleteBranch(String branchId) {
    final session = state.session;
    if (session == null || session is! BranchingSession) return;
    final bs = session as BranchingSession;
    final remaining = bs.branches.where((b) => b.id != branchId).toList();
    String? newCurrent = bs.currentBranchId;
    if (bs.currentBranchId == branchId) {
      newCurrent = remaining.isNotEmpty ? remaining.first.id : null;
    }
    final updated = bs.copyWith(
      branches: remaining,
      currentBranchId: newCurrent,
    );
    state = state.copyWith(session: updated);
    _persistSession(updated);
  }

  @override
  void dispose() {
    _cancelStream();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

// Convenience derived providers
final activeSessionProvider = Provider<Session?>(
  (ref) => ref.watch(chatProvider).session,
);
final isLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatProvider).isLoading,
);
final activeFilesProvider = Provider<List<FileReference>>(
  (ref) => ref.watch(chatProvider).activeFiles,
);
final selectedDiffProvider = Provider<FileDiff?>(
  (ref) => ref.watch(chatProvider).selectedDiff,
);
final editingMessageIdProvider = Provider<String?>(
  (ref) => ref.watch(chatProvider).editingMessageId,
);

final estimatedContextTokensProvider = Provider<int>((ref) {
  final chat = ref.watch(chatProvider);
  final settings = ref.watch(settingsProvider);
  return chat.estimateContextTokens(settings.systemPrompt);
});

final contextWindowFractionProvider = Provider<double>((ref) {
  final tokens = ref.watch(estimatedContextTokensProvider);
  final settings = ref.watch(settingsProvider);
  final windowSize = AppConstants.modelContextWindows[settings.model] ?? 200000;
  return (tokens / windowSize).clamp(0.0, 1.0);
});
