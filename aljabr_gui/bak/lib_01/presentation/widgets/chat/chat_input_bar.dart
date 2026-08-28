import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/language_detector.dart';
import '../../../features/chat/models/file_reference.dart';
import '../../../features/chat/models/prompt_snippet.dart';
import '../../../features/chat/states/chat_provider.dart';
import '../../providers/snippets_provider.dart';
import '../shared/context_usage_indicator.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  const ChatInputBar({super.key});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposing = false;
  List<PromptSnippet> _suggestions = [];
  int _selectedSuggestion = -1;
  bool _showPasteRunHint = false;

  String? _detectRunnableLang(String content) {
    final t = content.trim();
    if (t.startsWith('```')) {
      final first = t.split('\n').first.replaceAll('```', '').trim();
      if (first.isNotEmpty) return first.toLowerCase();
    }
    if (t.contains('\n')) {
      final lower = t.toLowerCase();
      if ((lower.contains('def ') || lower.contains('import ')) && lower.contains(':')) return 'python';
      if ((lower.contains('void main') || lower.contains('main(')) && lower.contains('{')) return 'dart';
    }
    return null;
  }

  bool get _hasRunnable => _detectRunnableLang(_controller.text) != null;

  Future<void> _runContent() async {
    final content = _controller.text;
    final lang = _detectRunnableLang(content) ?? '';
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code copied to clipboard for $lang (paste into REPL/terminal)'), duration: const Duration(seconds: 2)));
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() => _isComposing = text.trim().isNotEmpty);

    if (text.startsWith('/') && !text.contains(' ')) {
      final snippets = ref.read(snippetsProvider);
      final query = text.substring(1).toLowerCase();
      setState(() {
        _suggestions = snippets.where((s) => (s.shortcut ?? '').toLowerCase().contains(query)).toList();
        _selectedSuggestion = _suggestions.isNotEmpty ? 0 : -1;
      });
    } else if (_suggestions.isNotEmpty) {
      setState(() {
        _suggestions = [];
        _selectedSuggestion = -1;
      });
    }

    // detect paste-run (simple heuristic)
    if (!_showPasteRunHint && _detectRunnableLang(text) != null && text.length > 20) {
      setState(() => _showPasteRunHint = true);
      Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _showPasteRunHint = false); });
    }
  }

  void _applySnippet(PromptSnippet snippet) {
    _controller.text = snippet.content;
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    setState(() { _suggestions = []; _selectedSuggestion = -1; });
    _focusNode.requestFocus();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final match = ref.read(snippetsProvider.notifier).matchShortcut(text);
    if (match != null) { _applySnippet(match); return; }
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    setState(() { _isComposing = false; _suggestions = []; _selectedSuggestion = -1; });
    _focusNode.requestFocus();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.pickFiles(type: FileType.any, allowMultiple: true, withData: true);
    if (res == null) return;
    for (final f in res.files) {
      if (f.bytes == null) continue;
      final content = utf8DecodeOrFallback(f.bytes!);
      final lang = LanguageDetector.fromFileName(f.name);
      final fileRef = FileReference(id: generateId(), name: f.name, path: f.path ?? f.name, content: content, language: lang);
      ref.read(chatProvider.notifier).addFile(fileRef);
    }
  }

  void _openSnippetManager() {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Snippets', style: TextStyle(color: AppTheme.textPrimary)),
        content: SizedBox(width: 500, height: 400, child: Consumer(builder: (c, r, ch) {
          final list = r.watch(snippetsProvider);
          return ListView.separated(itemCount: list.length, separatorBuilder: (_,__) => const Divider(color: AppTheme.border), itemBuilder: (_,i) {
            final s = list[i];
            return ListTile(title: Text(s.title), subtitle: Text('/${s.shortcut ?? ''}'), onTap: () { Navigator.pop(context); _applySnippet(s); });
          });
        })),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final activeFiles = ref.watch(activeFilesProvider);
    return Container(
      decoration: BoxDecoration(color: AppTheme.surface, border: const Border(top: BorderSide(color: AppTheme.border, width: 0.5))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_suggestions.isNotEmpty) _SnippetSuggestions(suggestions: _suggestions, onSelect: _applySnippet, selectedIndex: _selectedSuggestion),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: const [Icon(Icons.keyboard, size: 14, color: AppTheme.textMuted), SizedBox(width: 8), Text('Enter to send · Shift+Enter for newline', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))])),
        if (activeFiles.isNotEmpty) _FileStrip(files: activeFiles),
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 4), child: Row(children: [const ContextUsageIndicator()])),
        Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _IconBtn(icon: Icons.attach_file, tooltip: 'Attach file', onTap: _pickFile),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.bolt_outlined, tooltip: 'Manage snippets', onTap: _openSnippetManager),
          const SizedBox(width: 8),
          Expanded(child: Stack(children: [
            TextField(controller: _controller, focusNode: _focusNode, maxLines: null, keyboardType: TextInputType.multiline, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), hintText: 'Type a message… ( / for snippets )'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            if (_showPasteRunHint) Positioned(left: 8, bottom: 8, child: ElevatedButton(onPressed: _runContent, child: const Text('Run pasted code'))),
            if (_hasRunnable) Positioned(right: 8, bottom: 8, child: ElevatedButton(onPressed: _runContent, child: const Text('Run'))),
          ])),
          const SizedBox(width: 8),
          if (isLoading) _IconBtn(icon: Icons.stop_circle, tooltip: 'Stop generating', color: AppTheme.error, onTap: () => ref.read(chatProvider.notifier).cancelStreaming()) else _SendButton(enabled: _isComposing, onTap: _send),
        ])),
      ]),
    );
  }
}

String utf8DecodeOrFallback(List<int> bytes) {
  try { return utf8.decode(bytes); } catch (_) { return latin1.decode(bytes); }
}

class _SnippetSuggestions extends StatelessWidget {
  const _SnippetSuggestions({required this.suggestions, required this.onSelect, this.selectedIndex = -1});
  final List<PromptSnippet> suggestions;
  final ValueChanged<PromptSnippet> onSelect;
  final int selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.fromLTRB(12,8,12,0), padding: const EdgeInsets.symmetric(vertical:8,horizontal:8), decoration: BoxDecoration(color: AppTheme.surfaceElevated, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border, width: 0.5)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: suggestions.map((s) {
      final i = suggestions.indexOf(s);
      final selected = i == selectedIndex;
      return Padding(padding: const EdgeInsets.only(right:8.0), child: InkWell(onTap: () => onSelect(s), child: Container(constraints: const BoxConstraints(minWidth:120), padding: const EdgeInsets.symmetric(horizontal:10, vertical:8), decoration: BoxDecoration(color: selected ? AppTheme.surface : AppTheme.background, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.title, maxLines:1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize:13,fontWeight: FontWeight.w600)), if ((s.shortcut ?? '').isNotEmpty) Text('/${s.shortcut}', style: const TextStyle(fontSize:11,color:AppTheme.textSecondary)), const SizedBox(height:6), Text(s.content.replaceAll('\n',' '), maxLines:1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize:12,color:AppTheme.textSecondary))]))));
    }).toList())));
  }
}

class _FileStrip extends ConsumerWidget { const _FileStrip({required this.files}); final List<FileReference> files; @override Widget build(BuildContext context, WidgetRef ref) { return Container(padding: const EdgeInsets.fromLTRB(12,8,12,0), child: Wrap(spacing:6, runSpacing:4, children: files.map((f) => _FileTag(file:f, onRemove: () => ref.read(chatProvider.notifier).removeFile(f.id))).toList())); }}

class _FileTag extends StatelessWidget { const _FileTag({required this.file, required this.onRemove}); final FileReference file; final VoidCallback onRemove; @override Widget build(BuildContext context) { return Container(padding: const EdgeInsets.only(left:8,right:2,top:3,bottom:3), decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(5), border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 0.5)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.insert_drive_file_outlined, size:12, color:AppTheme.accent), const SizedBox(width:5), Text(file.name, style: const TextStyle(color:AppTheme.accent,fontSize:12,fontWeight: FontWeight.w500)), const SizedBox(width:4), GestureDetector(onTap:onRemove, child: const Icon(Icons.close, size:13, color:AppTheme.accent))])); }}

class _SendButton extends StatelessWidget { const _SendButton({required this.enabled, required this.onTap}); final bool enabled; final VoidCallback onTap; @override Widget build(BuildContext context) { return GestureDetector(onTap: enabled ? onTap : null, child: AnimatedContainer(duration: const Duration(milliseconds:150), width:36, height:36, decoration: BoxDecoration(color: enabled ? AppTheme.accent : AppTheme.surfaceElevated, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.send_rounded, size:17, color: enabled ? Colors.white : AppTheme.textMuted))); }}

class _IconBtn extends StatelessWidget { const _IconBtn({required this.icon, required this.onTap, this.tooltip, this.color}); final IconData icon; final VoidCallback onTap; final String? tooltip; final Color? color; @override Widget build(BuildContext context) { return Tooltip(message: tooltip ?? '', child: GestureDetector(onTap:onTap, child: Container(width:34, height:34, decoration: BoxDecoration(color: AppTheme.surfaceElevated, borderRadius: BorderRadius.circular(7)), child: Icon(icon, size:17, color: color ?? AppTheme.textSecondary)))); }}

String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

