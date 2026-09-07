import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../../chat/providers/chat_transcript_provider.dart';
import '../models/composer_state.dart';
import '../models/composer_context.dart';

final composerProvider = StateNotifierProvider<ComposerNotifier, ComposerState>(
  (ref) => ComposerNotifier(ref),
);

class WorkspaceOperation {
  final String before;
  final String after;
  final String path;
  WorkspaceOperation(this.path, this.before, this.after);
}

class ComposerNotifier extends StateNotifier<ComposerState> {
  final Ref ref;
  final List<Attachment> _attachments = [];
  final List<WorkspaceOperation> _undoStack = [];

  ComposerNotifier(this.ref) : super(const ComposerState());

  void setText(String text) {
    state = state.copyWith(text: text, status: ComposerStatus.composing);
  }

  void setMode(ComposerMode mode) {
    state = state.copyWith(mode: mode);
  }

  Future<void> submit() async {
    if (state.text.trim().isEmpty && _attachments.isEmpty) return;
    state = state.copyWith(status: ComposerStatus.submitting);

    // Send message into chat transcript for current session
    try {
      final sessionId = ref.read(activeSessionIdProvider);
      await ref.read(chatTranscriptProvider(sessionId).notifier).addUserMessage(
          state.text.trim(),
          attachments: List.from(_attachments));
    } catch (e) {
      // ignore failures for now
    }

    // clear composer
    _attachments.clear();
    state = state
        .copyWith(status: ComposerStatus.completed, text: '', contexts: []);
  }

  /// Start an autonomous agent run (simulated): append a plan entry to the chat
  Future<void> startAgentRun(String planSummary, dynamic perms) async {
    state = state.copyWith(status: ComposerStatus.submitting);
    try {
      final sessionId = ref.read(activeSessionIdProvider);
      ref
          .read(chatTranscriptProvider(sessionId).notifier)
          .appendStep('Agent run started: $planSummary');
    } catch (_) {}
    state = state.copyWith(status: ComposerStatus.completed);
  }

  void addContext(ComposerContext ctx) {
    // avoid duplicates
    if (state.contexts.any((c) => c.id == ctx.id)) return;
    state = state.copyWith(contexts: [...state.contexts, ctx]);
  }

  void removeContext(String id) {
    state = state.copyWith(
        contexts: state.contexts.where((c) => c.id != id).toList());
  }

  void inspectContext(String id) {
    // Focus the editor or move context to front for now
    final idx = state.contexts.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      final ctx = state.contexts[idx];
      final others = state.contexts.where((c) => c.id != id).toList();
      state = state.copyWith(contexts: [ctx, ...others]);
    }
  }

  /// Suggest contexts from available editor providers and add them as suggested
  void suggestContextsFromEditor() {
    try {
      final activeFile = ref.read(activeFileProvider);
      if (activeFile.isNotEmpty) {
        addContext(ComposerContext(
            id: 'file:$activeFile',
            type: ComposerContextType.file,
            label: activeFile.split('/').last,
            path: activeFile));
      }

      // If there are highlighted lines, attach as selection context
      final highlighted = highlightedLineIndexes[activeFile] ?? {};
      if (highlighted.isNotEmpty) {
        final start = highlighted.first + 1;
        final end = highlighted.last + 1;
        addContext(ComposerContext(
            id: 'selection:$activeFile:$start-$end',
            type: ComposerContextType.selection,
            label: activeFile.split('/').last,
            path: activeFile,
            startLine: start,
            endLine: end));
      }
    } catch (e) {
      // ignore if providers not available during tests
    }
  }

  // Attachments
  List<Attachment> get attachments => List.unmodifiable(_attachments);
  void addAttachment(Attachment a) {
    _attachments.add(a);
  }

  void removeAttachment(String id) {
    _attachments.removeWhere((a) => a.id == id);
  }

  // Simple editor integration: insert or replace text in sampleFileContents (demo-only)
  void insertCode(String path, String code, {int? line}) {
    final file = sampleFileContents[path];
    if (file == null) return;
    final before = file.join('\n');
    final lines = List<String>.from(file);
    if (line == null) {
      lines.add(code);
    } else {
      final idx = (line - 1).clamp(0, lines.length);
      lines.insert(idx, code);
    }
    sampleFileContents[path] = lines;
    final after = lines.join('\n');
    _undoStack.add(WorkspaceOperation(path, before, after));
  }

  void replaceSelection(
      String path, int startLine, int endLine, String replacement) {
    final file = sampleFileContents[path];
    if (file == null) return;
    final before = file.join('\n');
    final lines = List<String>.from(file);
    final s = (startLine - 1).clamp(0, lines.length);
    final e = (endLine - 1).clamp(0, lines.length - 1);
    lines.replaceRange(s, e + 1, replacement.split('\n'));
    sampleFileContents[path] = lines;
    final after = lines.join('\n');
    _undoStack.add(WorkspaceOperation(path, before, after));
  }

  Future<void> undoLast() async {
    if (_undoStack.isEmpty) return;
    final op = _undoStack.removeLast();
    sampleFileContents[op.path] = op.before.split('\n');
  }
}
