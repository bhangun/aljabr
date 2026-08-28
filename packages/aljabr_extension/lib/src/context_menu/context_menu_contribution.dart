import 'dart:async';
import 'package:flutter/widgets.dart';
import '../commands/command_context.dart';

class ContextMenuContribution {
  final String id;
  final String location;
  final String title;
  final IconData? icon;
  final int order;
  final FutureOr<void> Function(CommandContext context)? action;

  const ContextMenuContribution({
    required this.id,
    required this.location,
    required this.title,
    this.icon,
    this.order = 0,
    this.action,
  });
}
