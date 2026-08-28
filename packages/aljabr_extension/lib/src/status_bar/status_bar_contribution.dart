import 'dart:async';
import 'package:flutter/widgets.dart';

enum StatusBarAlignment {
  left,
  right,
}

class StatusBarContribution {
  final String id;
  final String? text;
  final IconData? icon;
  final String? tooltip;
  final StatusBarAlignment alignment;
  final int order;
  final Widget Function(BuildContext context)? builder;
  final FutureOr<void> Function(BuildContext context)? onTap;

  const StatusBarContribution({
    required this.id,
    this.text,
    this.icon,
    this.tooltip,
    this.alignment = StatusBarAlignment.left,
    this.order = 0,
    this.builder,
    this.onTap,
  });
}
