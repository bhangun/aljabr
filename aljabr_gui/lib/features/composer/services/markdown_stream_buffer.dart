import 'dart:async';

class MarkdownStreamBuffer {
  final StringBuffer _buffer = StringBuffer();
  Timer? _timer;
  final Duration flushDelay;
  final void Function(String) onFlush;

  MarkdownStreamBuffer(
      {this.flushDelay = const Duration(milliseconds: 60),
      required this.onFlush});

  void append(String token) {
    _buffer.write(token);
    _timer ??= Timer(flushDelay, _flush);
  }

  void _flush() {
    _timer = null;
    onFlush(_buffer.toString());
  }

  /// Force an immediate flush
  void flush() {
    _timer?.cancel();
    _flush();
  }

  String get text => _buffer.toString();

  void clear() {
    _buffer.clear();
  }
}
