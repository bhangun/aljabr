import 'dart:async';
import 'package:flutter/widgets.dart';
import 'command_context.dart';

class AppCommand {
  final String id;
  final String title;
  final String? subtitle;
  final String category;
  final IconData? icon;
  final String? shortcut;
  final FutureOr<void> Function(CommandContext context)? action;

  const AppCommand({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    this.icon,
    this.shortcut,
    this.action,
  });
}
