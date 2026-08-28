import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A horizontal split view with a draggable divider between [left] and
/// [right]. Width is clamped between [minLeftWidth] and [maxLeftWidth].
class ResizableSplitView extends StatefulWidget {
  const ResizableSplitView({
    super.key,
    required this.left,
    required this.right,
    this.initialLeftWidth = 520,
    this.minLeftWidth = 360,
    this.maxLeftWidth = 800,
  });

  final Widget left;
  final Widget right;
  final double initialLeftWidth;
  final double minLeftWidth;
  final double maxLeftWidth;

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  late double _leftWidth = widget.initialLeftWidth;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxAllowed = (constraints.maxWidth - 240).clamp(widget.minLeftWidth, widget.maxLeftWidth);
        final clampedWidth = _leftWidth.clamp(widget.minLeftWidth, maxAllowed);

        return Row(
          children: [
            SizedBox(width: clampedWidth, child: widget.left),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _leftWidth = (clampedWidth + details.delta.dx).clamp(widget.minLeftWidth, maxAllowed);
                  });
                },
                onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
                child: Container(
                  width: 6,
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: _isDragging ? 2 : 0.5,
                      color: _isDragging ? AppTheme.accent : AppTheme.border,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: widget.right),
          ],
        );
      },
    );
  }
}
