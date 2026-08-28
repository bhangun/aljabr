import 'dart:async';
import 'package:flutter/widgets.dart';
import '../extensions/contribution.dart';
import 'menu_context.dart';

typedef MenuVisibilityPredicate = bool Function(MenuContext context);
typedef MenuEnabledPredicate = bool Function(MenuContext context);
typedef MenuAction = FutureOr<void> Function(MenuContext context);

class MenuContribution implements OwnedContribution {
  @override
  final String id;

  @override
  final String ownerId;

  final String targetId;
  final String label;
  final IconData? icon;
  final int order;
  final String? group;
  final MenuVisibilityPredicate? isVisible;
  final MenuEnabledPredicate? isEnabled;
  final MenuAction action;

  const MenuContribution({
    required this.id,
    required this.ownerId,
    required this.targetId,
    required this.label,
    required this.action,
    this.icon,
    this.order = 0,
    this.group,
    this.isVisible,
    this.isEnabled,
  });
}

// Backward compatible alias
typedef ContextMenuContribution = MenuContribution;
