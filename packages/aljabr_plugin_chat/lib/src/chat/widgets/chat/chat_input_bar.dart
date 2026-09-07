import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../../providers/chat_transcript_provider.dart';
import '../../providers/model_agent_providers.dart';
import '../../providers/session_provider.dart';
import '../input/input_container.dart';
import '../suggestion_overlay.dart';

/// Bottom composer: multi-line text field with autocomplete, model selector,
/// token usage, send button, file picker, and drag-and-drop attachments.
class ChatInputBar extends ConsumerStatefulWidget {
  final List<String> slashCommands;
  const ChatInputBar({super.key, required this.slashCommands});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final InputBarController _inputController = InputBarController();
  final List<Attachment> _pendingAttachments = [];
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _send() {
    logDebug('CHAT UI: _send triggered');
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;

    final sessionId = ref.read(activeSessionIdProvider);
    final targetSession = sessionId.isNotEmpty ? sessionId : kGeneralSessionId;
    logDebug('CHAT UI: sending to session "$targetSession"');
    ref.read(chatTranscriptProvider(targetSession).notifier).addUserMessage(
          text,
          attachments: List.from(_pendingAttachments),
        );
    _controller.clear();
    _inputController.clearSuggestions();
    setState(() => _pendingAttachments.clear());
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
    );
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        _pendingAttachments.add(_fileToAttachment(f.path!, f.name, f.size));
      }
    });
  }

  void _onDropDone(DropDoneDetails details) {
    setState(() {
      _isDragOver = false;
      for (final xFile in details.files) {
        final file = File(xFile.path);
        _pendingAttachments.add(
          _fileToAttachment(xFile.path, xFile.name, file.lengthSync()),
        );
      }
    });
  }

  Attachment _fileToAttachment(String path, String name, int size) {
    final ext = name.split('.').last.toLowerCase();
    final type = const {
      'png': AttachmentType.image,
      'jpg': AttachmentType.image,
      'jpeg': AttachmentType.image,
      'gif': AttachmentType.image,
      'webp': AttachmentType.image,
      'svg': AttachmentType.image,
      'mp3': AttachmentType.audio,
      'wav': AttachmentType.audio,
      'ogg': AttachmentType.audio,
      'mp4': AttachmentType.video,
      'mov': AttachmentType.video,
    }.containsKey(ext)
        ? const {
            'png': AttachmentType.image,
            'jpg': AttachmentType.image,
            'jpeg': AttachmentType.image,
            'gif': AttachmentType.image,
            'webp': AttachmentType.image,
            'svg': AttachmentType.image,
            'mp3': AttachmentType.audio,
            'wav': AttachmentType.audio,
            'ogg': AttachmentType.audio,
            'mp4': AttachmentType.video,
            'mov': AttachmentType.video,
          }[ext]!
        : AttachmentType.file;

    return Attachment(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      localPath: path,
      size: size,
      status: AttachmentStatus.ready,
    );
  }

  void _removeAttachment(String id) =>
      setState(() => _pendingAttachments.removeWhere((a) => a.id == id));

  @override
  Widget build(BuildContext context) {
    final sessionId = ref.watch(activeSessionIdProvider);
    final targetSession = sessionId.isNotEmpty ? sessionId : kGeneralSessionId;
    final (tokens, costUsd) = ref.watch(sessionUsageProvider(targetSession));
    final hasText = _controller.text.trim().isNotEmpty;
    final model = ref.watch(selectedModelProvider);

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragOver = true),
      onDragExited: (_) => setState(() => _isDragOver = false),
      onDragDone: _onDropDone,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: _isDragOver
            ? BoxDecoration(
                border: Border.all(color: AppTheme.accentBlue, width: 2),
                color: AppTheme.accentBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag-over hint ───────────────────────────────────────────
            if (_isDragOver)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_download_outlined,
                        size: 16, color: AppTheme.accentBlue),
                    SizedBox(width: 8),
                    Text("Drop files to attach",
                        style: TextStyle(
                            color: AppTheme.accentBlue, fontSize: 13)),
                  ],
                ),
              ),

            // ── Pending attachment chips ─────────────────────────────────
            if (_pendingAttachments.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.panelAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _pendingAttachments.map((a) {
                    final icon = switch (a.type) {
                      AttachmentType.image => Icons.image_outlined,
                      AttachmentType.audio => Icons.audiotrack_outlined,
                      AttachmentType.video => Icons.videocam_outlined,
                      _ => Icons.attach_file_outlined,
                    };
                    return Chip(
                      avatar: Icon(icon, size: 14, color: AppTheme.textMuted),
                      label: Text(
                        a.name.length > 24
                            ? '${a.name.substring(0, 21)}…'
                            : a.name,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppTheme.textPrimary),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 13),
                      onDeleted: () => _removeAttachment(a.id),
                      backgroundColor: AppTheme.chip,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ),

            // ── Autocomplete overlay ─────────────────────────────────────
            SuggestionsOverlay(
              controller: _controller,
              inputController: _inputController,
              onSelect: (suggestion) {
                _inputController.applySuggestion(suggestion);
                _focusNode.requestFocus();
              },
            ),

            // ── Main input row ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                Tooltip(
                  message: 'Attach files',
                  child: InkWell(
                    onTap: _pickFiles,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.attach_file_outlined,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InputContainer(
                    controller: _controller,
                    focusNode: _focusNode,
                    inputController: _inputController,
                    onSend: _send,
                    slashCommands: widget.slashCommands,
                    hasText: hasText || _pendingAttachments.isNotEmpty,
                    tokens: tokens,
                    costUsd: costUsd,
                    model: model,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
