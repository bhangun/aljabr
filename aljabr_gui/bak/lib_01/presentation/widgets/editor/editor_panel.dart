import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/chat/models/file_reference.dart';
import '../../../features/chat/states/chat_provider.dart';
import '../shared/shared_widgets.dart';

class EditorPanel extends ConsumerWidget {
  const EditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(activeFilesProvider);
    if (files.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open,
        message: 'No files open',
        subtitle:
            'Attach files from the chat input to view and edit them here.',
      );
    }
    return _TabbedEditor(files: files);
  }
}

class _TabbedEditor extends ConsumerStatefulWidget {
  const _TabbedEditor({required this.files});
  final List<FileReference> files;

  @override
  ConsumerState<_TabbedEditor> createState() => _TabbedEditorState();
}

class _TabbedEditorState extends ConsumerState<_TabbedEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.files.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void didUpdateWidget(_TabbedEditor old) {
    super.didUpdateWidget(old);
    if (old.files.length != widget.files.length) {
      final prev = _selectedIndex;
      _tabController.dispose();
      _tabController = TabController(
        length: widget.files.length,
        vsync: this,
        initialIndex: prev.clamp(0, widget.files.length - 1),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabBar(
          files: widget.files,
          controller: _tabController,
          selectedIndex: _selectedIndex,
        ),
        const CodexDivider(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.files.map((f) => FileEditor(file: f)).toList(),
          ),
        ),
      ],
    );
  }
}

class _TabBar extends ConsumerWidget {
  const _TabBar({
    required this.files,
    required this.controller,
    required this.selectedIndex,
  });
  final List<FileReference> files;
  final TabController controller;
  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: controller,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorColor: AppTheme.accent,
              indicatorWeight: 2,
              labelColor: AppTheme.textPrimary,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              tabs: files
                  .map(
                    (f) => Tab(
                      height: 34,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(f.name),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => ref
                                .read(chatProvider.notifier)
                                .removeFile(f.id),
                            child: const Icon(Icons.close, size: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FileEditor extends ConsumerStatefulWidget {
  const FileEditor({super.key, required this.file});
  final FileReference file;

  @override
  ConsumerState<FileEditor> createState() => _FileEditorState();
}

class _FileEditorState extends ConsumerState<FileEditor> {
  late TextEditingController _controller;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.content);
  }

  @override
  void didUpdateWidget(FileEditor old) {
    super.didUpdateWidget(old);
    if (old.file.content != widget.file.content && !_editMode) {
      _controller.text = widget.file.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(chatProvider.notifier)
        .updateFileContent(widget.file.id, _controller.text);
    setState(() => _editMode = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EditorToolbar(
          file: widget.file,
          editMode: _editMode,
          onToggleEdit: () => setState(() => _editMode = !_editMode),
          onSave: _save,
        ),
        const CodexDivider(),
        Expanded(
          child: _editMode
              ? _EditableContent(controller: _controller)
              : _ReadOnlyContent(file: widget.file),
        ),
        _StatusBar(file: widget.file),
      ],
    );
  }
}

class _EditorToolbar extends StatefulWidget {
  const _EditorToolbar({
    required this.file,
    required this.editMode,
    required this.onToggleEdit,
    required this.onSave,
  });
  final FileReference file;
  final bool editMode;
  final VoidCallback onToggleEdit;
  final VoidCallback onSave;

  @override
  State<_EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<_EditorToolbar> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.file.content));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.file.path,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
            ),
          ),
          if (widget.editMode) ...[
            CodexButton(
              label: 'Save',
              icon: Icons.save,
              onPressed: widget.onSave,
              small: true,
            ),
            const SizedBox(width: 6),
            CodexButton(
              label: 'Cancel',
              onPressed: widget.onToggleEdit,
              variant: ButtonVariant.ghost,
              small: true,
            ),
          ] else ...[
            Tooltip(
              message: _copied ? 'Copied!' : 'Copy file contents',
              child: GestureDetector(
                onTap: _copy,
                child: Icon(
                  _copied ? Icons.check : Icons.copy_outlined,
                  size: 14,
                  color: _copied ? AppTheme.success : AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CodexButton(
              label: 'Edit',
              icon: Icons.edit_outlined,
              onPressed: widget.onToggleEdit,
              variant: ButtonVariant.ghost,
              small: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadOnlyContent extends StatelessWidget {
  const _ReadOnlyContent({required this.file});
  final FileReference file;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          file.content,
          language: file.language.isEmpty ? 'plaintext' : file.language,
          theme: atomOneDarkTheme,
          textStyle: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 12.5,
            height: 1.65,
          ),
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _EditableContent extends StatelessWidget {
  const _EditableContent({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      expands: true,
      style: AppTheme.monoStyle,
      cursorColor: AppTheme.accent,
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.file});
  final FileReference file;

  @override
  Widget build(BuildContext context) {
    final lines = '\n'.allMatches(file.content).length + 1;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.surfaceElevated,
      child: Row(
        children: [
          Text(
            file.language.isEmpty ? 'Plain text' : file.language,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 16),
          Text(
            '$lines lines',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 16),
          Text(
            '${file.content.length} chars',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
