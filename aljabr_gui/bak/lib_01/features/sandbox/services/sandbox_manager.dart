import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../../coding_agent.dart';
import 'sanbox_config.dart';

/// Manages secure code execution in isolated environments
class SandboxManager {
  SandboxManager._();
  static final SandboxManager _instance = SandboxManager._();
  static SandboxManager get instance => _instance;

  final Map<String, Process> _runningProcesses = {};
  final Map<String, Directory> _sandboxDirs = {};
  final _config = SandboxConfig.defaultConfig;

  /// Execute code in a sandboxed environment
  Future<Result<SandboxResult>> execute({
    required String code,
    required String language,
    Duration? timeout,
    bool captureOutput = true,
  }) async {
    final executionId = _generateExecutionId();
    final sandboxDir = await _createSandboxDirectory(executionId);

    try {
      // Write code to sandbox
      final codeFile = await _writeCodeFile(sandboxDir, code, language);

      // Determine execution command
      final command = _getExecutionCommand(language, codeFile.path);

      // Run with timeout and measure duration
      final start = DateTime.now();
      final result = await _runWithTimeout(
        command,
        sandboxDir.path,
        timeout ?? _config.defaultTimeout,
      );
      final duration = DateTime.now().difference(start);

      // Parse output
      final output = _parseOutput(result);

      // Cleanup
      await _cleanupSandbox(executionId);

      return Success(
        SandboxResult(
          output: output,
          exitCode: result.exitCode,
          executionTime: duration,
        ),
      );
    } catch (e) {
      await _cleanupSandbox(executionId);
      return Failure(ExecutionError('Sandbox execution failed: $e'));
    }
  }

  /// Create a temporary sandbox directory
  Future<Directory> _createSandboxDirectory(String id) async {
    final tempDir = await Directory.systemTemp.createTemp('sandbox_$id');
    _sandboxDirs[id] = tempDir;
    return tempDir;
  }

  /// Write code file with proper extension
  Future<File> _writeCodeFile(
    Directory dir,
    String code,
    String language,
  ) async {
    final ext = _getFileExtension(language);
    final filePath = path.join(dir.path, 'main.$ext');
    final file = File(filePath);
    await file.writeAsString(code);
    return file;
  }

  /// Get execution command for language
  List<String> _getExecutionCommand(String language, String filePath) {
    switch (language) {
      case 'dart':
        return ['dart', filePath];
      case 'python':
        return ['python3', filePath];
      case 'javascript':
        return ['node', filePath];
      case 'bash':
        return ['bash', filePath];
      default:
        throw ArgumentError('Unsupported language: $language');
    }
  }

  /// Run process with timeout
  Future<ProcessResult> _runWithTimeout(
    List<String> command,
    String workingDirectory,
    Duration timeout,
  ) async {
    final completer = Completer<ProcessResult>();

    final process = await Process.start(
      command.first,
      command.skip(1).toList(),
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    final id = _generateExecutionId();
    _runningProcesses[id] = process;

    // Set timeout
    final timer = Timer(timeout, () {
      process.kill();
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Execution timed out'));
      }
    });

    // Collect output
    final stdout = StringBuffer();
    final stderr = StringBuffer();

    process.stdout.listen((data) {
      stdout.write(utf8.decode(data));
    });

    process.stderr.listen((data) {
      stderr.write(utf8.decode(data));
    });

    final exitCode = await process.exitCode;
    timer.cancel();
    _runningProcesses.remove(id);

    if (!completer.isCompleted) {
      completer.complete(
        ProcessResult(
          process.pid,
          exitCode,
          stdout.toString(),
          stderr.toString(),
        ),
      );
    }

    return completer.future;
  }

  /// Parse process output
  String _parseOutput(ProcessResult result) {
    final output = result.stdout.toString().trim();
    final error = result.stderr.toString().trim();

    if (result.exitCode != 0) {
      return 'Error (exit code ${result.exitCode}):\n$error';
    }

    if (output.isEmpty && error.isEmpty) {
      return '✓ Execution completed successfully (no output)';
    }

    return output.isNotEmpty ? output : error;
  }

  /// Clean up sandbox
  Future<void> _cleanupSandbox(String id) async {
    // Kill any running processes
    _runningProcesses.remove(id)?.kill();

    // Delete sandbox directory
    final dir = _sandboxDirs.remove(id);
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  String _getFileExtension(String language) {
    switch (language) {
      case 'dart':
        return 'dart';
      case 'python':
        return 'py';
      case 'javascript':
        return 'js';
      case 'bash':
        return 'sh';
      default:
        return 'txt';
    }
  }

  String _generateExecutionId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }
}

/// Sandbox execution result
class SandboxResult {
  const SandboxResult({
    required this.output,
    required this.exitCode,
    required this.executionTime,
  });

  final String output;
  final int exitCode;
  final Duration executionTime;

  bool get success => exitCode == 0;
}
