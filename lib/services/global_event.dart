import 'dart:async';

class GlobalEvent {
  static final GlobalEvent _instance = GlobalEvent._internal();
  factory GlobalEvent() => _instance;
  GlobalEvent._internal();

  final StreamController<String> _eventController = StreamController<String>.broadcast();

  Stream<String> get eventStream => _eventController.stream;

  void emitEvent(String event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}
