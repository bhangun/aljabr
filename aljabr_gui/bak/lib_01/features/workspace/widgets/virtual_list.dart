import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A memory-efficient message list that only renders visible items
class VirtualMessageList<T> extends StatefulWidget {
  const VirtualMessageList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.estimatedItemHeight = 80.0,
    this.cacheExtent = 500.0,
    this.padding,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final double estimatedItemHeight;
  final double cacheExtent;
  final EdgeInsets? padding;

  @override
  State<VirtualMessageList<T>> createState() => _VirtualMessageListState<T>();
}

class _VirtualMessageListState<T> extends State<VirtualMessageList<T>> {
  final ScrollController _controller = ScrollController();
  final Map<int, double> _itemHeights = {};
  double _viewportHeight = 0;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 50), () {
      if (mounted) _updateVisibleRange();
    });
  }

  void _updateVisibleRange() {
    if (!mounted || _viewportHeight == 0) return;

    final offset = _controller.offset;
    final startIndex = (offset / widget.estimatedItemHeight).floor();
    final endIndex = ((offset + _viewportHeight) / widget.estimatedItemHeight)
        .ceil();

    setState(() {
      _firstVisibleIndex = (startIndex - 2).clamp(0, widget.items.length - 1);
      _lastVisibleIndex = (endIndex + 2).clamp(0, widget.items.length - 1);
    });
  }

  double _getItemHeight(int index) {
    return _itemHeights[index] ?? widget.estimatedItemHeight;
  }

  double _getTotalHeight() {
    return widget.items.fold<double>(
      0,
      (sum, _) => sum + widget.estimatedItemHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportHeight = constraints.maxHeight;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateVisibleRange();
        });

        return Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          child: ListView.builder(
            controller: _controller,
            padding: widget.padding,
            itemCount: widget.items.length,
            cacheExtent: widget.cacheExtent,
            itemBuilder: (context, index) {
              // Show placeholder for off-screen items
              if (index < _firstVisibleIndex || index > _lastVisibleIndex) {
                return SizedBox(
                  height: _getItemHeight(index),
                  child: Container(
                    color: index.isEven
                        ? AppTheme.surface
                        : AppTheme.surfaceElevated,
                  ),
                );
              }

              return _MeasuredItem(
                index: index,
                item: widget.items[index],
                builder: widget.itemBuilder,
                onHeightMeasured: (height) {
                  if (_itemHeights[index] != height) {
                    setState(() => _itemHeights[index] = height);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MeasuredItem<T> extends StatefulWidget {
  const _MeasuredItem({
    required this.index,
    required this.item,
    required this.builder,
    required this.onHeightMeasured,
  });

  final int index;
  final T item;
  final Widget Function(BuildContext, T, int) builder;
  final void Function(double) onHeightMeasured;

  @override
  State<_MeasuredItem> createState() => _MeasuredItemState();
}

class _MeasuredItemState extends State<_MeasuredItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureHeight();
    });
  }

  void _measureHeight() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      widget.onHeightMeasured(renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.item, widget.index);
  }
}
