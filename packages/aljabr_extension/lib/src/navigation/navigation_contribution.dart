import 'dart:async';
import 'package:flutter/widgets.dart';

class NavigationContribution {
  final String id;
  final String groupId;
  final String label;
  final IconData? icon;
  final String? viewId;
  final int order;
  final FutureOr<void> Function(BuildContext context)? action;

  const NavigationContribution({
    required this.id,
    required this.groupId,
    required this.label,
    this.icon,
    this.viewId,
    this.order = 0,
    this.action,
  });
}
