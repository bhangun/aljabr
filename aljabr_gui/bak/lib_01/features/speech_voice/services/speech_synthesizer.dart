import 'dart:async';
import '../../../core/utils/result.dart';

/// Lightweight stub TTS implementation used when flutter_tts isn't available.
class SpeechSynthesizer {
  SpeechSynthesizer();

  /// Speak text (stub)
  Future<Result<void>> speak(String text) async {
    // In absence of real TTS dependency, simulate speaking delay.
    await Future.delayed(const Duration(milliseconds: 200));
    return const Success(null);
  }

  /// Stop speaking (stub)
  Future<void> stop() async {
    // No-op for stub
    await Future.value();
  }

  void dispose() {}
}