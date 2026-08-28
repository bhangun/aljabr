import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../coding_agent.dart';
import 'speech_recognizer.dart';
import 'speech_synthesizer.dart';

/// Voice interface manager
class VoiceManager {
  VoiceManager._();
  static final VoiceManager _instance = VoiceManager._();
  static VoiceManager get instance => _instance;

  final SpeechRecognizer _recognizer = SpeechRecognizer();
  final SpeechSynthesizer _synthesizer = SpeechSynthesizer();

  bool _isListening = false;
  bool _isSpeaking = false;
  final StreamController<VoiceEvent> _eventController =
      StreamController<VoiceEvent>.broadcast();

  /// Start voice recognition
  Future<Result<void>> startListening() async {
    if (_isListening) return const Success(null);

    try {
      _isListening = true;
      _eventController.add(VoiceListeningStarted());

      final result = await _recognizer.startListening();
      result.fold(
        onSuccess: (_) {
          _eventController.add(VoiceStatusEvent('listening'));
        },
        onFailure: (error) {
          _isListening = false;
          _eventController.add(VoiceError(error.message));
        },
      );
      return result;
    } catch (e) {
      _isListening = false;
      return Failure(NetworkError('Failed to start listening: $e'));
    }
  }

  /// Stop voice recognition
  Future<Result<String>> stopListening() async {
    if (!_isListening) {
      return const Success('');
    }

    _isListening = false;
    _eventController.add(VoiceListeningStopped());

    final result = await _recognizer.stopListening();
    return result.fold(
      onSuccess: (text) {
        if (text.isNotEmpty) {
          _eventController.add(VoiceRecognized(text));
        }
        return Success(text);
      },
      onFailure: (error) => Failure(error),
    );
  }

  /// Speak text
  Future<Result<void>> speak(String text) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }

    _isSpeaking = true;
    _eventController.add(VoiceSpeakingStarted());

    try {
      final result = await _synthesizer.speak(text);
      _isSpeaking = false;
      _eventController.add(VoiceSpeakingFinished());
      return result;
    } catch (e) {
      _isSpeaking = false;
      _eventController.add(VoiceError(e.toString()));
      return Failure(NetworkError('Failed to speak: $e'));
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _synthesizer.stop();
      _isSpeaking = false;
      _eventController.add(VoiceSpeakingStopped());
    }
  }

  /// Check if listening
  bool get isListening => _isListening;

  /// Check if speaking
  bool get isSpeaking => _isSpeaking;

  /// Voice events stream
  Stream<VoiceEvent> get events => _eventController.stream;

  void dispose() {
    _recognizer.dispose();
    _synthesizer.dispose();
    _eventController.close();
  }
}

/// Voice event types
sealed class VoiceEvent {
  const VoiceEvent();
}

class VoiceListeningStarted extends VoiceEvent {}

class VoiceListeningStopped extends VoiceEvent {}

class VoiceRecognized extends VoiceEvent {
  VoiceRecognized(this.text);
  final String text;
}

class VoiceSpeakingStarted extends VoiceEvent {}

class VoiceSpeakingFinished extends VoiceEvent {}

class VoiceSpeakingStopped extends VoiceEvent {}

class VoiceError extends VoiceEvent {
  VoiceError(this.message);
  final String message;
}

class VoiceStatusEvent extends VoiceEvent {
  VoiceStatusEvent(this.type);
  final String type;
}
