import 'dart:async';

import 'package:flutter_mvu/src/event.dart';

class BroadcastStream<T> {
  final _streamController = StreamController<T>.broadcast();
  StreamSink<T> get sink => _streamController.sink;
  Stream<T> get stream => _streamController.stream;

  void dispose() {
    sink.close();
    stream.drain();
  }
}

class ModelEventStream<T> extends BroadcastStream<Event<T>> {}
