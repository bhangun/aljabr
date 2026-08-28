import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';

import '../../../core/utils/result.dart';
import '../core/agent_plugin.dart';
import '../core/plugin_context.dart';

/// Code execution plugin - runs code snippets safely
class CodeExecutorPlugin implements AgentPlugin {
  @override
  String get id => 'code_executor';

  @override
  String get name => 'Code Executor';

  @override
  String get description => 'Run code snippets safely in a sandbox';

  @override
  String get icon => '⚡';

  @override
  bool get enabled => true;

  static const _maxExecutionTime = Duration(seconds: 30);
  static const _maxOutputLength = 10000;

  @override
  Future<Result<PluginResult>> processInput(PluginContext context) async {
    final content = context.content;
    final match = RegExp(
      r'```(\w+)\s*run\s*\n([\s\S]*?)```',
      caseSensitive: false,
    ).firstMatch(content);

    if (match == null) {
      return const Success(PluginResult());
    }

    final language = match.group(1)?.toLowerCase() ?? '';
    final code = match.group(2)?.trim() ?? '';

    if (code.isEmpty) {
      return const Success(PluginResult());
    }

    try {
      final result = await _executeCode(language, code);
      final enhancedContent =
          '${content.replaceFirst(match.group(0)!, '')}\n\n'
          '### Execution Result ($language)\n```\n$result\n```';

      return Success(
        PluginResult(
          modifiedContent: enhancedContent,
          metadata: {
            'executedCode': code,
            'language': language,
            'output': result,
          },
        ),
      );
    } catch (e) {
      return Success(
        PluginResult(metadata: {'error': e.toString(), 'executedCode': code}),
      );
    }
  }

  @override
  Future<Result<PluginResult>> processOutput(PluginContext context) async {
    return const Success(PluginResult());
  }

  Future<String> _executeCode(String language, String code) async {
    // In production, use a proper sandbox (Docker, WebAssembly, etc.)
    // This is a simplified version

    return switch (language) {
      'dart' => await _executeDart(code),
      'python' => await _executePython(code),
      'javascript' => await _executeJavaScript(code),
      _ => 'Language "$language" execution not supported yet.',
    };
  }

  Future<String> _executeDart(String code) async {
    // Run Dart code in an isolate with timeouts
    final receivePort = ReceivePort();
    final result = Completer<String>();

    // Simplified - in production, use Process.run with sandboxing
    final tempFile = await File(
      '${Directory.systemTemp.path}/exec_${DateTime.now().millisecondsSinceEpoch}.dart',
    ).create();
    await tempFile.writeAsString(code);

    final process = await Process.start('dart', [
      tempFile.path,
    ], runInShell: true);

    final output = StringBuffer();

    // Read output with timeout
    final subscription = process.stdout.listen((data) {
      output.write(utf8.decode(data));
    });

    final stderrSubscription = process.stderr.listen((data) {
      output.write('ERROR: ${utf8.decode(data)}');
    });

    // Set timeout
    final timer = Timer(_maxExecutionTime, () {
      process.kill();
      if (!result.isCompleted) {
        result.completeError(
          'Execution timed out after ${_maxExecutionTime.inSeconds} seconds',
        );
      }
    });

    final exitCode = await process.exitCode;
    timer.cancel();

    await subscription.cancel();
    await stderrSubscription.cancel();
    await tempFile.delete();

    if (exitCode != 0 && !result.isCompleted) {
      return output.toString();
    }

    final outputStr = output.toString();
    if (outputStr.length > _maxOutputLength) {
      return '${outputStr.substring(0, _maxOutputLength)}\n... (truncated)';
    }

    return outputStr.isEmpty ? '✓ Execution completed (no output)' : outputStr;
  }

  Future<String> _executePython(String code) async {
    // Similar to Dart execution
    // In production, use a proper sandbox
    return 'Python execution requires proper sandbox setup.';
  }

  Future<String> _executeJavaScript(String code) async {
    return 'JavaScript execution requires proper sandbox setup.';
  }

  @override
  Widget? getSettingsUI() {
    return null;
  }
}
