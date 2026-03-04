import 'dart:async';

import 'package:flutter_mvu/src/event.dart';
import 'package:flutter_mvu/src/sink_and_stream.dart';

class GlobalEventQueue {
  static final BroadcastStream<GlobalEvent> _globalEventStream =
      BroadcastStream<GlobalEvent>();

  static StreamSink<GlobalEvent> get globalEventSink => _globalEventStream.sink;

  static Stream<GlobalEvent> get globalEventStream => _globalEventStream.stream;
}
