import 'dart:async';
import 'package:flutter/widgets.dart';
import '../extensions/contribution.dart';
import 'status_bar_alignment.dart';
import 'status_bar_context.dart';

typedef StatusBarTextBuilder = String Function(StatusBarContext context);
typedef StatusBarAction = FutureOr<void> Function(
  BuildContext context,
  StatusBarContext statusContext,
);
typedef StatusBarWidgetBuilder = Widget Function(
  BuildContext context,
  StatusBarContext statusContext,
);

class StatusBarContribution implements OwnedContribution {
  @override
  final String id;

  @override
  final String ownerId;

  final StatusBarAlignment alignment;
  final StatusBarItemKind kind;
  final int order;
  final String? tooltip;
  final IconData? icon;
  final String? commandId;
  final StatusBarTextBuilder? textBuilder;
  final StatusBarAction? action;
  final StatusBarWidgetBuilder? builder;
  final bool Function(StatusBarContext context)? isVisible;
  final bool Function(StatusBarContext context)? isEnabled;

  const StatusBarContribution({
    required this.id,
    required this.ownerId,
    this.alignment = StatusBarAlignment.start,
    this.kind = StatusBarItemKind.text,
    this.order = 0,
    this.tooltip,
    this.icon,
    this.commandId,
    this.textBuilder,
    this.action,
    this.builder,
    this.isVisible,
    this.isEnabled,
  });
}
