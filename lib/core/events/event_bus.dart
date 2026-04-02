import 'dart:async';
import 'app_event.dart';

class EventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  void emit(AppEvent event) {
    _controller.add(event);
  }

  Stream<AppEvent> get stream => _controller.stream;
}

final eventBus = EventBus();
