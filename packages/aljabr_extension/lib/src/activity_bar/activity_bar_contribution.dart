import 'dart:async';
import 'package:flutter/widgets.dart';
import '../extensions/contribution.dart';

enum ActivityBarPlacement {
  top,
  bottom,
}

class ActivityBarContribution implements OwnedContribution {
  @override
  final String id;

  @override
  final String ownerId;

  final String title;
  final IconData icon;
  final ActivityBarPlacement placement;
  final int order;
  final String? viewId;
  final FutureOr<void> Function(BuildContext context)? action;

  const ActivityBarContribution({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.icon,
    this.placement = ActivityBarPlacement.top,
    this.order = 0,
    this.viewId,
    this.action,
  });
}
