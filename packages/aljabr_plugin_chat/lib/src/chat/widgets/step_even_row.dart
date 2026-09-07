import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'loading_spinner.dart';

/// Collapsible one-line step event row with optional spinner

/// Collapsible one-line "Worked for 16s" / "Timed 60 seconds" event row,
/// with a chevron and optional spinner for in-flight steps.
class StepEventRow extends StatefulWidget {
  final ChatEntry entry;
  const StepEventRow({super.key, required this.entry});

  @override
  State<StepEventRow> createState() => _StepEventRowState();
}

class _StepEventRowState extends State<StepEventRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            if (widget.entry.isLoading) const LoadingSpinner(),
            const Gap(8),
            Flexible(
              child: Text(
                widget.entry.text,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
