import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/errors/app_error.dart';
import '../../../core/utils/result.dart';
import '../core/agent_plugin.dart';
import '../core/plugin_context.dart';

/// Web search plugin - enhances responses with web information
class WebSearchPlugin implements AgentPlugin {
  @override
  String get id => 'web_search';

  @override
  String get name => 'Web Search';

  @override
  String get description => 'Search the web for relevant information';

  @override
  String get icon => '🌐';

  @override
  bool get enabled => true;

  @override
  Future<Result<PluginResult>> processInput(PluginContext context) async {
    // Detect if web search is needed
    final triggers = ['search:', 'find:', 'look up', 'latest', 'current'];
    final shouldSearch = triggers.any(
      (t) => context.content.toLowerCase().contains(t),
    );

    if (!shouldSearch) {
      return const Success(PluginResult());
    }

    // Extract search query
    final query = _extractQuery(context.content);
    if (query.isEmpty) {
      return const Success(PluginResult());
    }

    try {
      // In production, use a real search API
      final results = await _mockSearch(query);
      final metadata = {'searchQuery': query, 'searchResults': results};

      // Add results to context
      final enhancedContent =
          '${context.content}\n\n[Web Search Results for "$query"]\n$results';

      return Success(
        PluginResult(modifiedContent: enhancedContent, metadata: metadata),
      );
    } catch (e) {
      return Failure(NetworkError('Search failed: $e'));
    }
  }

  @override
  Future<Result<PluginResult>> processOutput(PluginContext context) async {
    // Post-process to add citations
    if (!context.previousResults.containsKey(id)) {
      return const Success(PluginResult());
    }

    // Add citations to the response
    final results = context.previousResults[id]?.metadata['searchResults'] as String?;
    if (results == null) {
      return const Success(PluginResult());
    }

    final enhanced = '${context.content}\n\n---\n_${results}_';
    return Success(
      PluginResult(
        modifiedContent: enhanced,
        metadata: {'citationsAdded': true},
      ),
    );
  }

  String _extractQuery(String content) {
    // Simple query extraction
    final patterns = [
      r'search:\s*([^\n]+)',
      r'find:\s*([^\n]+)',
      r'look up\s*([^\n]+)',
    ];
    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(content);
      if (match != null) return match.group(1)?.trim() ?? '';
    }
    return '';
  }

  Future<String> _mockSearch(String query) async {
    // In production, call a search API
    await Future.delayed(const Duration(milliseconds: 500));
    return '• Found 3 results for "$query":\n'
        '  1. Result 1: Relevant information\n'
        '  2. Result 2: More details\n'
        '  3. Result 3: Additional context';
  }

  @override
  Widget? getSettingsUI() {
    // Return a settings widget if needed
    return null;
  }
}
