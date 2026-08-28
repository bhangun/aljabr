import 'package:http/http.dart' as http;

import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';
import '../chat/models/message.dart';
import 'anthropic_provider.dart';

/// Abstract interface for all model providers
abstract class ModelProvider {
  /// Stream completion with token-by-token delivery
  Stream<Result<String>> streamCompletion(ModelRequest request);

  /// Non-streaming completion
  Future<Result<String>> complete(ModelRequest request);

  /// Get the model's context window size
  int getContextWindow();

  /// Get the model's maximum output tokens
  int getMaxOutputTokens();

  /// Get the provider name
  String get name;
}

/// Standard request object for all providers
class ModelRequest {
  const ModelRequest({
    required this.messages,
    this.systemPrompt,
    this.maxTokens = 8192,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.stopSequences = const [],
  });

  final List<Message> messages;
  final String? systemPrompt;
  final int maxTokens;
  final double temperature;
  final double topP;
  final List<String> stopSequences;

  /// Convert to provider-specific format
  Map<String, dynamic> toMap(Map<String, dynamic> overrides) {
    return {
      'model': overrides['model'],
      'messages': messages.map(_toMessageMap).toList(),
      'max_tokens': maxTokens,
      'temperature': temperature,
      'top_p': topP,
      'stop': stopSequences,
      ...overrides,
    };
  }

  Map<String, dynamic> _toMessageMap(Message m) {
    return {
      'role': m.role == MessageRole.user ? 'user' : 'assistant',
      'content': m.content,
    };
  }
}

/// Factory for creating providers
class ModelProviderFactory {
  static ModelProvider create({
    required String providerType,
    required String apiKey,
    http.Client? client,
  }) {
    switch (providerType.toLowerCase()) {
      case 'default':
        return DefaultProvider(apiKey: apiKey, client: client);
      case 'openai':
        throw UnimplementedError(
          'OpenAI provider is not implemented in this build.',
        );
      case 'local':
        throw UnimplementedError(
          'Local provider is not implemented in this build.',
        );
      default:
        throw ArgumentError('Unknown provider: $providerType');
    }
  }
}
