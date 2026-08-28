import 'package:flutter/material.dart';
import 'command_id.dart';

enum CommandCategory {
  editor,
  agent,
  verification,
  navigation,
  enterprise,
}

class AppCommand {
  final CommandId id;
  final String title;
  final String? subtitle;
  final CommandCategory category;
  final IconData icon;
  final String? shortcut;
  final Future<void> Function(BuildContext context)? action;

  const AppCommand({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.icon,
    this.shortcut,
    this.action,
  });
}
