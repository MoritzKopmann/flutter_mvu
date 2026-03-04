import 'package:flutter_mvu/src/event.dart';

abstract class GlobalEventConsumer<T> {
  void processGlobalEvent(
      GlobalEvent globalEvent, Function(Event<T> event) triggerEvent);
}
