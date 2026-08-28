import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mutation_providers.dart';
import '../../../data/backend_providers.dart';

class MutationPanel extends ConsumerWidget {
  const MutationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsAsync = ref.watch(mutationIdsProvider);
    return Container(
      width: 320,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: const Text('MUTATIONS',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          Expanded(
            child: idsAsync.when(
              data: (ids) {
                if (ids.isEmpty) {
                  return const Center(child: Text('No mutations recorded'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: ids.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, idx) {
                    final id = ids[idx];
                    return ListTile(
                      title: Text(id, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new, size: 18),
                        onPressed: () async {
                          final svc = ref.read(backendServiceProvider);
                          final content = await svc.readMutation(id);
                          if (content == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Record not found')));
                            return;
                          }
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.6,
                              minChildSize: 0.3,
                              maxChildSize: 0.95,
                              builder: (_, ctl) => Container(
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  controller: ctl,
                                  child: SelectableText(content,
                                      style: const TextStyle(
                                          fontFamily: 'monospace')),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Failed to load: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
