import 'package:flutter/material.dart';
import 'package:flutter_mvu/flutter_mvu.dart';
import 'package:flutter_mvu/src/global_event_consumer.dart';

/// A widget that binds a [ModelController] to a [StateView], rebuilding
/// whenever the model emits a new state. Supports two construction modes:
///
/// 1. Passing a raw [model] and [_stateView]: the provider creates its own
///    [ModelController] and disposes it automatically (autoDispose = true).
/// 2. Passing an existing [controller] and [_stateView]: the provider uses the
///    provided controller without auto-disposal (autoDispose = false).
class ModelProvider<T extends Object> extends StatefulWidget {
  final ModelController<T> _controller;
  final StateView<T> _stateView;
  final bool _autoDispose;

  /// Constructs a provider by creating a new [ModelController] for [model].
  /// The controller will be disposed automatically when this widget is removed.
  ModelProvider(
    T model, {
    super.key,
    List<Event<T>> initialEvents = const [],
    GlobalEventConsumer<T>? globalEventConsumer,
    required StateView<T> stateView,
  })  : _stateView = stateView,
        _controller = ModelController<T>(model,
            initialEvents: initialEvents,
            globalEventConsumer: globalEventConsumer),
        _autoDispose = true;

  /// Constructs a provider using an existing [controller].
  /// In this mode, autoDispose is disabled, and you must dispose the controller
  /// yourself when it's no longer needed.
  const ModelProvider.controller(
    ModelController<T> controller, {
    super.key,
    required StateView<T> stateView,
  })  : _stateView = stateView,
        _controller = controller,
        _autoDispose = false;

  @override
  State<ModelProvider<T>> createState() => _ModelProviderState<T>();
}

class _ModelProviderState<T extends Object> extends State<ModelProvider<T>> {
  @override
  void dispose() {
    if (widget._autoDispose) {
      widget._controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget._controller.stream,
      initialData: widget._controller.model,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null) {
          return Container();
        }
        return widget._stateView.view(
          context,
          state,
          widget._controller.triggerEvent,
        );
      },
    );
  }
}
