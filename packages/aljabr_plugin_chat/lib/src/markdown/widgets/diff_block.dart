import 'package:flutter/material.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// Diff block: colours +/- lines green/red.
class DiffBlock extends StatelessWidget {
  final String code;
  const DiffBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border))),
            child: const Row(children: [
              Icon(Icons.difference_outlined,
                  size: 13, color: AppTheme.textMuted),
              SizedBox(width: 6),
              Text('diff',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontFamily: 'monospace')),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) {
                Color bg = Colors.transparent;
                Color fg = AppTheme.textSecondary;
                if (line.startsWith('+') && !line.startsWith('+++')) {
                  bg = const Color(0xFF1A3A1A);
                  fg = const Color(0xFF6DDC6D);
                } else if (line.startsWith('-') && !line.startsWith('---')) {
                  bg = const Color(0xFF3A1A1A);
                  fg = const Color(0xFFDC6D6D);
                } else if (line.startsWith('@@')) {
                  fg = const Color(0xFF6DB3DC);
                }
                return Container(
                  width: double.infinity,
                  color: bg,
                  child: Text(
                    line,
                    style: TextStyle(
                      color: fg,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
