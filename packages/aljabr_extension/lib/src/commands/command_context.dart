import 'package:flutter/widgets.dart';

class CommandContext {
  final BuildContext context;
  final String? projectId;
  final String? sessionId;

  const CommandContext({
    required this.context,
    this.projectId,
    this.sessionId,
  });
}
