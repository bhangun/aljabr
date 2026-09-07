import 'package:flutter/material.dart';

enum ToolCallKind {
  readFile,
  editFile,
  runCommand,
  search,
  webFetch,
  batch,
  multiple,
  parallel,
  findReferences,
  findDependencies,
  findRelatedFiles,
  findSymbol,
  build,
  runTest,
  lint,
  format,
  staticAnalysis
}

enum ToolCallStatus {
  queued, // Waiting in queue
  pending, // Waiting for approval
  running, // Currently executing
  success, // Completed successfully
  error, // Failed with error
  cancelled, // Cancelled by user
  suspended // Temporarily paused
}

extension ToolCallKindX on ToolCallKind {
  IconData get icon {
    switch (this) {
      case ToolCallKind.readFile:
        return Icons.description_outlined;
      case ToolCallKind.editFile:
        return Icons.edit_note;
      case ToolCallKind.runCommand:
        return Icons.terminal;
      case ToolCallKind.search:
        return Icons.search;
      case ToolCallKind.webFetch:
        return Icons.public;
      case ToolCallKind.batch:
      case ToolCallKind.multiple:
      case ToolCallKind.parallel:
        return Icons.account_tree;
      case ToolCallKind.findReferences:
        return Icons.compare_arrows;
      case ToolCallKind.findDependencies:
        return Icons.schema;
      case ToolCallKind.findRelatedFiles:
        return Icons.file_present;
      case ToolCallKind.findSymbol:
        return Icons.code;
      case ToolCallKind.build:
        return Icons.build_circle_outlined;
      case ToolCallKind.runTest:
        return Icons.play_circle_outline;
      case ToolCallKind.lint:
        return Icons.rule;
      case ToolCallKind.format:
        return Icons.auto_fix_high;
      case ToolCallKind.staticAnalysis:
        return Icons.security;
    }
  }

  String get verb {
    switch (this) {
      case ToolCallKind.readFile:
        return 'Read file';
      case ToolCallKind.editFile:
        return 'Edit file';
      case ToolCallKind.runCommand:
        return 'Run command';
      case ToolCallKind.search:
        return 'Search';
      case ToolCallKind.webFetch:
        return 'Fetch URL';
      case ToolCallKind.batch:
        return 'Batch operation';
      case ToolCallKind.multiple:
        return 'Multiple operations';
      case ToolCallKind.parallel:
        return 'Parallel operations';
      case ToolCallKind.findReferences:
        return 'Find references';
      case ToolCallKind.findDependencies:
        return 'Find dependencies';
      case ToolCallKind.findRelatedFiles:
        return 'Find related files';
      case ToolCallKind.findSymbol:
        return 'Find symbol';
      case ToolCallKind.build:
        return 'Build';
      case ToolCallKind.runTest:
        return 'Run test';
      case ToolCallKind.lint:
        return 'Lint';
      case ToolCallKind.format:
        return 'Format';
      case ToolCallKind.staticAnalysis:
        return 'Static analysis';
    }
  }

  static ToolCallKind fromString(String kind) {
    final normalized =
        kind.toLowerCase().replaceAll('.', '_').replaceAll('-', '_');
    switch (normalized) {
      case 'read_file':
      case 'readfile':
        return ToolCallKind.readFile;
      case 'write_file':
      case 'edit_file':
      case 'editfile':
      case 'workspace_patch':
      case 'patch':
        return ToolCallKind.editFile;
      case 'run_command':
      case 'runcommand':
      case 'terminal':
      case 'exec':
      case 'execute':
        return ToolCallKind.runCommand;
      case 'list_directory':
      case 'listdirectory':
      case 'search':
      case 'find':
      case 'git_status':
      case 'workspace_info':
        return ToolCallKind.search;
      case 'web_fetch':
      case 'webfetch':
        return ToolCallKind.webFetch;
      case 'batch':
        return ToolCallKind.batch;
      case 'multiple':
        return ToolCallKind.multiple;
      case 'parallel':
        return ToolCallKind.parallel;
      case 'find_references':
      case 'findreferences':
        return ToolCallKind.findReferences;
      case 'find_dependencies':
      case 'finddependencies':
        return ToolCallKind.findDependencies;
      case 'find_related_files':
      case 'findrelatedfiles':
        return ToolCallKind.findRelatedFiles;
      case 'find_symbol':
      case 'findsymbol':
        return ToolCallKind.findSymbol;
      case 'build':
      case 'compile':
        return ToolCallKind.build;
      case 'run_test':
      case 'runtest':
      case 'test':
        return ToolCallKind.runTest;
      case 'lint':
        return ToolCallKind.lint;
      case 'format':
        return ToolCallKind.format;
      case 'static_analysis':
      case 'staticanalysis':
        return ToolCallKind.staticAnalysis;
      default:
        for (final val in ToolCallKind.values) {
          if (val.name.toLowerCase() == normalized) {
            return val;
          }
        }
        return ToolCallKind.runCommand;
    }
  }
}

extension ToolCallStatusX on ToolCallStatus {
  Color get color {
    switch (this) {
      case ToolCallStatus.success:
        return const Color(0xFF34C759);
      case ToolCallStatus.error:
        return const Color(0xFFFF3B30);
      case ToolCallStatus.running:
        return const Color(0xFF4C8DFF);
      case ToolCallStatus.pending:
      case ToolCallStatus.queued:
        return const Color(0xFFE0A94C);
      case ToolCallStatus.cancelled:
        return const Color(0xFF6E6E6E);
      case ToolCallStatus.suspended:
        return const Color(0xFF9B9B9B);
    }
  }
}
