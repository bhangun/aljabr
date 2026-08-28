import 'package:flutter/material.dart';
import 'app_command.dart';
import 'command_id.dart';

class CommandRegistry {
  final Map<CommandId, AppCommand> _commands = {};

  CommandRegistry() {
    _registerDefaults();
  }

  void register(AppCommand command) {
    _commands[command.id] = command;
  }

  AppCommand? get(CommandId id) => _commands[id];

  List<AppCommand> getAll() => _commands.values.toList();

  List<AppCommand> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final q = query.toLowerCase().trim();
    return _commands.values.where((c) {
      return c.title.toLowerCase().contains(q) ||
          (c.subtitle != null && c.subtitle!.toLowerCase().contains(q)) ||
          c.category.name.toLowerCase().contains(q);
    }).toList();
  }

  void _registerDefaults() {
    // Editor
    register(const AppCommand(
      id: CommandId.saveFile,
      title: 'File: Save',
      subtitle: 'Save active editor document',
      category: CommandCategory.editor,
      icon: Icons.save_outlined,
      shortcut: '⌘S',
    ));
    register(const AppCommand(
      id: CommandId.goToFile,
      title: 'Go to File...',
      subtitle: 'Quick open files in workspace',
      category: CommandCategory.navigation,
      icon: Icons.folder_open_outlined,
      shortcut: '⌘P',
    ));
    register(const AppCommand(
      id: CommandId.goToSymbol,
      title: 'Go to Symbol in Workspace...',
      subtitle: 'Search functions, classes, and methods',
      category: CommandCategory.navigation,
      icon: Icons.code_rounded,
      shortcut: '⌘⇧O',
    ));

    // Agent & AI
    register(const AppCommand(
      id: CommandId.askAgent,
      title: 'Aljabr: Ask Agent',
      subtitle: 'Prompt the autonomous agent on current context',
      category: CommandCategory.agent,
      icon: Icons.auto_awesome,
      shortcut: '⌘K',
    ));
    register(const AppCommand(
      id: CommandId.explainSelection,
      title: 'Aljabr: Explain Selection',
      subtitle: 'AI breakdown of highlighted code block',
      category: CommandCategory.agent,
      icon: Icons.help_outline_rounded,
      shortcut: '⌘⇧E',
    ));
    register(const AppCommand(
      id: CommandId.reviewChanges,
      title: 'Aljabr: Review ChangeSet',
      subtitle: 'Inspect granular hunks and diff explanations',
      category: CommandCategory.agent,
      icon: Icons.difference_outlined,
      shortcut: '⌘⇧D',
    ));

    // Verification
    register(const AppCommand(
      id: CommandId.runTargetedTests,
      title: 'Verification: Run Targeted Tests (L2)',
      subtitle: 'Execute only test suites affected by AST diffs',
      category: CommandCategory.verification,
      icon: Icons.play_arrow_rounded,
      shortcut: '⌘T',
    ));
    register(const AppCommand(
      id: CommandId.verifyLadderL0L5,
      title: 'Verification: Run Full Verification Ladder (L0–L5)',
      subtitle: 'Syntax, Typecheck, Targeted, Global, SAST, Invariants',
      category: CommandCategory.verification,
      icon: Icons.verified_outlined,
    ));

    // Panels
    register(const AppCommand(
      id: CommandId.toggleTerminal,
      title: 'View: Toggle Integrated Terminal',
      subtitle: 'Show or hide bottom terminal console',
      category: CommandCategory.navigation,
      icon: Icons.terminal_rounded,
      shortcut: '⌃`',
    ));
    register(const AppCommand(
      id: CommandId.toggleProblems,
      title: 'View: Toggle Problems & Diagnostics Panel',
      subtitle: 'Inspect compiler errors, warnings, and code smells',
      category: CommandCategory.navigation,
      icon: Icons.warning_amber_rounded,
      shortcut: '⌘⇧M',
    ));

    // Enterprise
    register(const AppCommand(
      id: CommandId.openBackendInfrastructure,
      title: 'Infrastructure: Dual-Backend Supervisor',
      subtitle: 'Manage Gollek & Wayang daemons, boot order, updates',
      category: CommandCategory.enterprise,
      icon: Icons.dns_rounded,
    ));
    register(const AppCommand(
      id: CommandId.openEnterpriseCompliance,
      title: 'Enterprise: Security & Compliance Center',
      subtitle: 'Cryptographic Audit Ledger, PII Redactor, Circuit Breaker',
      category: CommandCategory.enterprise,
      icon: Icons.verified_user_rounded,
    ));
  }
}
