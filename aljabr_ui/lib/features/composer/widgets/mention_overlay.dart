import 'package:flutter/material.dart';
import '../../editor/providers/sample.dart' show sampleFileContents;
import '../models/composer_context.dart';

/// Simple mention overlay presented as a bottom sheet. In a full UI this
/// should be an anchored overlay near the caret.
Future<void> showMentionOverlay(BuildContext context, String query,
    Function(ComposerContext) onSelect) async {
  final results = <String>[];
  final q = query.toLowerCase();
  for (final p in sampleFileContents.keys) {
    final name = p.split('/').last;
    if (name.toLowerCase().contains(q)) results.add(p);
  }

  await showModalBottomSheet(
    context: context,
    builder: (ctx) {
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (c, i) {
          final path = results[i];
          return ListTile(
            title: Text(path.split('/').last),
            subtitle: Text(path),
            onTap: () {
              onSelect(ComposerContext(
                  id: 'file:$path',
                  type: ComposerContextType.file,
                  label: path.split('/').last,
                  path: path));
              Navigator.of(ctx).pop();
            },
          );
        },
      );
    },
  );
}
