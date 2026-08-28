import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_providers.dart';
import '../../providers/explorer_providers.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_colors.dart';

const _slashCommands = [
  '/explain — walk through what changed and why',
  '/fix — attempt to fix the current test/build failure',
  '/tests — run the test suite',
  '/commit — stage and commit the current changes',
  '/revert — discard pending changes in this session',
];

/// Bottom composer: multi-line text field with `@file` and `/command`
/// autocomplete, a model-selector chip + live token/cost usage on the left
/// footer, mic + send buttons on the right.
class ChatInputBar extends ConsumerStatefulWidget {
  const ChatInputBar({super.key});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _controller = TextEditingController();

  String? _triggerChar; // '@' or '/'
  int _triggerStart = -1;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    if (cursor < 0 || cursor > text.length) {
      _clearSuggestions();
      return;
    }

    // Walk back from the cursor to the nearest '@' or '/' that isn't
    // separated from it by a space — that's the "word" being typed.
    int i = cursor - 1;
    while (i >= 0 && text[i] != ' ' && text[i] != '\n') {
      if (text[i] == '@' || text[i] == '/') break;
      i--;
    }
    if (i < 0 || (text[i] != '@' && text[i] != '/')) {
      _clearSuggestions();
      return;
    }
    // '/' only triggers autocomplete right at the start of a message —
    // otherwise "10/20" or similar would pop up commands mid-sentence.
    if (text[i] == '/' && i != 0) {
      _clearSuggestions();
      return;
    }

    final trigger = text[i];
    final query = text.substring(i + 1, cursor).toLowerCase();
    final pool = trigger == '@' ? ref.read(filePathsProvider) : _slashCommands;
    final matches = pool
        .where((p) => p.toLowerCase().contains(query))
        .take(6)
        .toList();

    setState(() {
      _triggerChar = trigger;
      _triggerStart = i;
      _suggestions = matches;
    });
  }

  void _clearSuggestions() {
    if (_suggestions.isEmpty && _triggerChar == null) return;
    setState(() {
      _suggestions = [];
      _triggerChar = null;
    });
  }

  void _applySuggestion(String value) {
    final display = _triggerChar == '@' ? '@$value' : value.split(' — ').first;
    final cursor = _controller.selection.baseOffset;
    final safeCursor = cursor < 0 ? _controller.text.length : cursor;
    final newText = _controller.text.replaceRange(
      _triggerStart,
      safeCursor,
      '$display ',
    );
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _triggerStart + display.length + 1,
      ),
    );
    _clearSuggestions();
  }

  void _send() {
    final sessionId = ref.read(activeSessionIdProvider);
    ref
        .read(chatTranscriptProvider(sessionId).notifier)
        .addUserMessage(_controller.text);
    _controller.clear();
    _clearSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(selectedModelProvider);
    final sessionId = ref.watch(activeSessionIdProvider);
    final (tokens, costUsd) = ref.watch(sessionUsageProvider(sessionId));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_suggestions.isNotEmpty)
            _SuggestionsList(
              trigger: _triggerChar!,
              suggestions: _suggestions,
              onSelect: _applySuggestion,
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
            decoration: BoxDecoration(
              color: AppTheme.panelAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Ask anything, @ to mention, / for actions',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _ModelSelector(model: model),
                    const SizedBox(width: 10),
                    _UsageChip(tokens: tokens, costUsd: costUsd),
                    const Spacer(),
                    const Icon(
                      Icons.mic_none,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _send,
                      borderRadius: BorderRadius.circular(20),
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.accentBlue,
                        child: Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating-feeling suggestions list shown above the composer while typing
/// an `@file` mention or a `/command`.
class _SuggestionsList extends StatelessWidget {
  final String trigger;
  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  const _SuggestionsList({
    required this.trigger,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in suggestions)
            InkWell(
              onTap: () => onSelect(s),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      trigger == '@' ? Icons.description_outlined : Icons.bolt,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModelSelector extends ConsumerWidget {
  final String model;
  const _ModelSelector({required this.model});

  static const _options = [
    'Gemini 3.1 Pro (High)',
    'Claude Sonnet 5',
    'Claude Opus 4.8',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      color: AppTheme.panelAlt,
      onSelected: (v) => ref.read(selectedModelProvider.notifier).state = v,
      itemBuilder: (context) => [
        for (final o in _options)
          PopupMenuItem(
            value: o,
            child: Text(o, style: const TextStyle(color: AppTheme.textPrimary)),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            model,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }
}

/// Small "12.4K tokens · $0.19" pill showing session usage so far.
class _UsageChip extends StatelessWidget {
  final int tokens;
  final double costUsd;
  const _UsageChip({required this.tokens, required this.costUsd});

  @override
  Widget build(BuildContext context) {
    final tokenLabel = tokens >= 1000
        ? '${(tokens / 1000).toStringAsFixed(1)}K'
        : '$tokens';
    return Tooltip(
      message: 'Estimated tokens and cost for this session',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.query_stats, size: 13, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            '$tokenLabel tokens · \$${costUsd.toStringAsFixed(2)}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
