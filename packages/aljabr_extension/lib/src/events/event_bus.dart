import 'dart:async';

class EventBus {
  final StreamController<Object> _controller =
      StreamController<Object>.broadcast();

  void emit(Object event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  Stream<T> on<T>() {
    return _controller.stream.where((e) => e is T).cast<T>();
  }

  Future<void> dispose() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
