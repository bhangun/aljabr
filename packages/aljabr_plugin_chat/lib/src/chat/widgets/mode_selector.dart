import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../providers/model_agent_providers.dart';

class ModelSelector extends ConsumerStatefulWidget {
  const ModelSelector({super.key});

  @override
  ConsumerState<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends ConsumerState<ModelSelector> {
  final TextEditingController _modelController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  void _showModelSelectionDialog(
      BuildContext context, List<Map<String, dynamic>> options) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.panel,
          title: const Text('Select or Enter Model',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _modelController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText:
                        'Custom Model ID (e.g., hf:unsloth/gemma-4-12b-it-GGUF)',
                    labelStyle: TextStyle(color: AppTheme.textMuted),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.border)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.accentBlue)),
                  ),
                  onSubmitted: (val) {
                    ref.read(selectedModelProvider.notifier).select(val);
                    Navigator.of(context).pop();
                  },
                ),
                const Gap(16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Available Local Models:',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                const Gap(8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final m = options[index];
                      final displayName = (m['name'] != null &&
                              m['name'].toString().isNotEmpty &&
                              m['name'] != 'unknown')
                          ? m['name'].toString()
                          : (m['id'] ?? '');
                      final format = (m['format'] ?? '').toString();
                      final sizeBytes = m['sizeBytes'];
                      String sizeStr = '';
                      if (sizeBytes is int && sizeBytes > 0) {
                        if (sizeBytes >= 1024 * 1024 * 1024) {
                          sizeStr =
                              ' • ${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
                        } else if (sizeBytes >= 1024 * 1024) {
                          sizeStr =
                              ' • ${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
                        }
                      }

                      return ListTile(
                        title: Text(displayName,
                            style:
                                const TextStyle(color: AppTheme.textPrimary)),
                        subtitle: Text('$format$sizeStr',
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 11)),
                        onTap: () {
                          final val = (m['id'] ?? displayName) as String;
                          _modelController.text = val;
                          ref.read(selectedModelProvider.notifier).select(val);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
            TextButton(
              onPressed: () {
                if (_modelController.text.isNotEmpty) {
                  ref
                      .read(selectedModelProvider.notifier)
                      .select(_modelController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm',
                  style: TextStyle(color: AppTheme.accentBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(selectedProviderProvider);
    final providerOptionsAsync = ref.watch(providerOptionsProvider);
    final model = ref.watch(selectedModelProvider);
    final modelOptionsAsync = ref.watch(modelOptionsProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        providerOptionsAsync.when(
          data: (options) {
            String activeProvider = provider.isEmpty && options.isNotEmpty
                ? options.first['id'] as String
                : provider;

            String providerName = activeProvider;
            for (final p in options) {
              if (p['id'] == activeProvider) {
                providerName = p['name'] as String;
                break;
              }
            }

            return PopupMenuButton<String>(
              color: AppTheme.panelAlt,
              onSelected: (v) {
                ref.read(selectedProviderProvider.notifier).select(v);
                ref.read(selectedModelProvider.notifier).select('');
              },
              itemBuilder: (context) => options
                  .map((o) => PopupMenuItem(
                        value: o['id'] as String,
                        child: Text(o['name'] as String,
                            style:
                                const TextStyle(color: AppTheme.textPrimary)),
                      ))
                  .toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    providerName.isEmpty ? 'Provider' : providerName,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const Gap(2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, st) =>
              const Icon(Icons.error, size: 16, color: Colors.red),
        ),
        const Gap(8),
        Container(width: 1, height: 16, color: AppTheme.border),
        const Gap(8),
        modelOptionsAsync.when(
          data: (options) {
            String activeModel = model.isEmpty && options.isNotEmpty
                ? options.first['id'] as String
                : model;

            final String displayModel =
                activeModel.isEmpty ? 'Select Model' : activeModel;

            return InkWell(
              onTap: () {
                _modelController.text = activeModel;
                _showModelSelectionDialog(context, options);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayModel,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const Gap(2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, st) =>
              const Icon(Icons.error, size: 16, color: Colors.red),
        ),
      ],
    );
  }
}
