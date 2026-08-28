import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../services/voice_manager.dart';

/// Voice input button for chat
class VoiceInputButton extends ConsumerStatefulWidget {
  const VoiceInputButton({super.key, required this.onVoiceInput});

  final ValueChanged<String> onVoiceInput;

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  final VoiceManager _voiceManager = VoiceManager.instance;
  bool _isListening = false;
  String? _transcript;

  @override
  void initState() {
    super.initState();
    _voiceManager.events.listen((event) {
      if (event is VoiceRecognized) {
        setState(() {
          _transcript = event.text;
        });
        if (event.text.isNotEmpty) {
          widget.onVoiceInput(event.text);
        }
      }
      if (event is VoiceListeningStopped) {
        setState(() {
          _isListening = false;
        });
      }
      if (event is VoiceError) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice error: ${event.message}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _voiceManager.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      final result = await _voiceManager.stopListening();
      result.fold(
        onSuccess: (text) {
          if (text.isNotEmpty) {
            widget.onVoiceInput(text);
          }
        },
        onFailure: (_) {},
      );
      setState(() => _isListening = false);
    } else {
      final result = await _voiceManager.startListening();
      if (result.isSuccess) {
        setState(() => _isListening = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _isListening ? AppTheme.error : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isListening ? AppTheme.error : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          size: 17,
          color: _isListening ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
