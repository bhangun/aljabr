import 'dart:async';
import 'package:flutter/widgets.dart';
import '../commands/command_context.dart';

class ToolbarContribution {
  final String id;
  final String title;
  final IconData icon;
  final String? tooltip;
  final int order;
  final FutureOr<void> Function(CommandContext context)? action;

  const ToolbarContribution({
    required this.id,
    required this.title,
    required this.icon,
    this.tooltip,
    this.order = 0,
    this.action,
  });
}
