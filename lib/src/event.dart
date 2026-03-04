/// Represents an event that updates a model of type [T].
///
/// Implementers must define [updateModel] to specify how the model is updated.
abstract class Event<T> {
  /// Updates [model] based on the event.
  ///
  /// must be synchronous
  void updateModel(
    T model,
    Function(Event<T> event) triggerEvent,
    Function(GlobalEvent globalEvent) triggerGlobalEvent,
  );
}

/// Represents a message from a module to a global event queue, to message anyone interested
abstract class GlobalEvent {}
