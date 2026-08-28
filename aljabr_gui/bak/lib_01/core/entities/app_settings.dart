import 'package:equatable/equatable.dart';

enum AiProvider { claude, wayangPro }

class AppSettings extends Equatable {
  const AppSettings({
    this.provider = AiProvider.claude,
    this.wayangProBaseUrl = 'http://localhost:8080',
    this.apiKey = '',
    this.model = 'claude-sonnet-4-6',
    this.maxTokens = 8192,
    this.systemPrompt = defaultSystemPrompt,
    this.streamingEnabled = true,
    this.fontSize = 13.0,
    this.tabSize = 2,
  });

  final AiProvider provider;
  final String wayangProBaseUrl;

  final String apiKey;
  final String model;
  final int maxTokens;
  final String systemPrompt;
  final bool streamingEnabled;
  final double fontSize;
  final int tabSize;

  static const defaultSystemPrompt = '''You are an expert coding assistant. 
When asked to modify code, always provide the full updated file content.
Format code changes clearly with file paths and language identifiers.
Be concise and precise. Explain what changed and why.''';

  AppSettings copyWith({
    AiProvider? provider,
    String? wayangProBaseUrl,
    String? apiKey,
    String? model,
    int? maxTokens,
    String? systemPrompt,
    bool? streamingEnabled,
    double? fontSize,
    int? tabSize,
  }) => AppSettings(
    provider: provider ?? this.provider,
    wayangProBaseUrl: wayangProBaseUrl ?? this.wayangProBaseUrl,
    apiKey: apiKey ?? this.apiKey,
    model: model ?? this.model,
    maxTokens: maxTokens ?? this.maxTokens,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    streamingEnabled: streamingEnabled ?? this.streamingEnabled,
    fontSize: fontSize ?? this.fontSize,
    tabSize: tabSize ?? this.tabSize,
  );

  bool get hasApiKey => apiKey.isNotEmpty;

  @override
  List<Object?> get props => [
    provider,
    wayangProBaseUrl,
    apiKey,
    model,
    maxTokens,
    systemPrompt,
    streamingEnabled,
    fontSize,
    tabSize,
  ];
}
