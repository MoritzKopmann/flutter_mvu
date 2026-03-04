import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_mvu/src/event.dart';
import 'package:flutter_mvu/src/global_event_consumer.dart';
import 'package:flutter_mvu/src/global_event_queue.dart';
import 'package:flutter_mvu/src/sink_and_stream.dart';

/// Manages the state and the model, and processes [events]
//
class ModelController<T extends Object> {
  final T _model;
  T get model => _model;

  final _events = ModelEventStream<T>();
  final _stateStream = BroadcastStream<T>();

  ModelController(this._model,
      {List<Event<T>> initialEvents = const [],
      GlobalEventConsumer<T>? globalEventConsumer}) {
    _initEventStreamListener();
    notifyListeners();
    for (Event<T> event in initialEvents) {
      triggerEvent(event);
    }
    if (globalEventConsumer != null) {
      GlobalEventQueue.globalEventStream.listen((globalEvent) =>
          globalEventConsumer.processGlobalEvent(globalEvent, triggerEvent));
    }
  }

  Stream<T> get stream => _stateStream.stream;

  void triggerEvent(Event<T> event) {
    assert(() {
      debugPrint("Triggering event: ${event.runtimeType}");
      return true;
    }());
    _events.sink.add(event);
  }

  void _initEventStreamListener() {
    // Fire off a detached async function
    () async {
      await for (final Event<T> event in _events.stream) {
        event.updateModel(_model, triggerEvent, _triggerGlobalEvent);
        notifyListeners();
      }
    }();
  }

  void _triggerGlobalEvent(GlobalEvent outEvent) {
    assert(() {
      debugPrint("Triggering global-event: ${outEvent.runtimeType}");
      return true;
    }());
    GlobalEventQueue.globalEventSink.add(outEvent);
  }

  void notifyListeners() {
    _stateStream.sink.add(_model);
  }

  @mustCallSuper
  void dispose() {
    _stateStream.dispose();
    _events.dispose();
  }
}
