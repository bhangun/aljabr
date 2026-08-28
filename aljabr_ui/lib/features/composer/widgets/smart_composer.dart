import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/composer_provider.dart';
import 'context_chips.dart';
import 'composer_toolbar.dart';
import 'mention_overlay.dart';

class SmartComposer extends ConsumerStatefulWidget {
  const SmartComposer({super.key});

  @override
  ConsumerState<SmartComposer> createState() => _SmartComposerState();
}

class _SmartComposerState extends ConsumerState<SmartComposer> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    controller.addListener(() {
      ref.read(composerProvider.notifier).setText(controller.text);
      _onTextChanged(controller.text);
    });

    // Suggest initial contexts from editor providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(composerProvider.notifier).suggestContextsFromEditor();
    });
  }

  bool _mentionOpen = false;

  void _onTextChanged(String text) {
    // detect simple @mention token at end of text
    final cursor = controller.selection.baseOffset;
    if (cursor <= 0) return;
    final before = text.substring(0, cursor);
    final at = before.lastIndexOf('@');
    if (at < 0) return;
    final query = before.substring(at + 1);
    if (query.contains(' ') || query.isEmpty) return;

    if (!_mentionOpen) {
      _mentionOpen = true;
      // show overlay as bottom sheet
      showMentionOverlay(context, query, (ctx) {
        ref.read(composerProvider.notifier).addContext(ctx);
        _mentionOpen = false;
      }).whenComplete(() => _mentionOpen = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerProvider);

    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          ContextChips(contexts: state.contexts),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Ask Aljabr...',
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          const ComposerToolbar(),
        ],
      ),
    );
  }

  void _submit() {
    if (controller.text.trim().isEmpty) return;
    ref.read(composerProvider.notifier).submit();
    controller.clear();
    focusNode.unfocus();
  }
}
