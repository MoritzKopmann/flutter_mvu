# flutter_mvu 🚀🎉

A minimal Elm-inspired Model-View-Update (MVU) state management library for Flutter. Predictable, testable, and boilerplate-free! 😎✨

---

## 📦 Installation 🔧

1. **Add to `pubspec.yaml`**:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_mvu: ^1.0.3
   ```
2. **Fetch packages**:
   ```bash
   flutter pub get
   ```
3. **Import** into your Dart files:
   ```dart
   import 'package:flutter_mvu/mvu.dart';
   ```

> **Compatibility**: Supports Dart ≥2.17 and Flutter ≥3.0 with full null-safety.

---

## 💡 Concept Overview

At the heart of **MVU** are four simple ideas:

1. **Model**: Your app's state – any plain Dart object holding data; **no base class or mixin required**.
2. **Event**: A message describing _what happened_ (user tap, data fetched, etc.).
3. **Update**: The `updateModel` method inside your `Event<T>` implementation—where you define how the `Model` changes in response to the `Event`.
4. **View**: A Flutter widget that renders the current `Model` and _emits_ `Event<T>` events via the provided `triggerEvent` callback.

Unidirectional flow:
```
User Interaction ➡️ Event ➡️ updateModel ➡️ Model Updated ➡️ View Rebuild ➡️ ...
```

This clear flow ensures that all state changes are predictable, easy to trace, and simple to test. 🛤️🔍

---

## 📝 API Summary 📋

### 🔸 ModelController<T>
Manages a model instance, processes events, emits states, and optionally dispatches initial events.

```dart
class ModelController<T extends Object> {
  ModelController(
    T model, {
    List<Event<T>> initialEvents = const [],
  });

  T get model;
  Stream<T> get stream;

  void triggerEvent(Event<T> event);
  void notifyListeners();
  void dispose();
}
```

- **Constructor**:
  - `ModelController(model)` — no initial events.
  - `ModelController(model, initialEvents: [...])` — enqueues those right after initialization.

- **Properties**:
  - `model`: the current state instance.
  - `stream`: a broadcast stream of state snapshots.

- **Methods**:
  - `triggerEvent(event)`: enqueue an `Event<T>` for processing within the module.
  - `notifyListeners()`: manually emit the current model into `stream`.
  - `dispose()`: close all internal streams and free resources.

---

### 🔸 Event<T>
Defines how to update the `Model` when something happens.

```dart
abstract class Event<T> {
  void updateModel(
    T model,
    void Function(Event<T>) triggerEvent,
    void Function(GlobalEvent) triggerGlobalEvent,
  );
}
```

- Implement `Event<T>` and override `updateModel` to update the model.
- Use `triggerEvent` to chain further events within your module.
- Use `triggerGlobalEvent` to trigger events readable by every module.
- Add attributes to the Event, which are being set by the constructor, to create parameterized events 

---

### 🔸 GlobalEvent<T>
Type for events that are communicated to every module

```dart
abstract class GlobalEvent {}
```

Emit via `triggerGlobalEvent(...)` inside `updateModel`.

To consume implement the abstract class

```dart
abstract class GlobalEventConsumer<T> {
  void processGlobalEvent(
      GlobalEvent globalEvent, Function(Event<T> event) triggerEvent);
}
```

and pass it to the ModelController.


---

### 🔸 StateView<T>
Defines how to render UI for a given state.

```dart
abstract class StateView<T> {
  Widget view(
    BuildContext context,
    T currentState,
    void Function(Event<T>) triggerEvent,
  );
}
```

- Build pure functions: no internal state, just `context`, `state`, `triggerEvent`.

---

### 🔸 ModelProvider<T>
A `StatefulWidget` that binds a `ModelController<T>` to a `StateView<T>`.

- **Auto-managed** constructor:
  ```dart
  ModelProvider(
    MyModel(),            // your raw model
    stateView: MyView(),  // your StateView implementation
    initialEvents: [],    // optional list of initial events to be triggered after model initialization
  )
  ```
  • Creates its own `ModelController` and **auto-disposes** it.

- **Self-managed** constructor:
  ```dart
  ModelProvider.controller(
    myController,        // existing ModelController
    stateView: MyView(),
  )
  ```
  • Uses your controller and **does not dispose** it; you manage lifecycle.

⚠️ **For self-managed controllers, remember to call `controller.dispose()` when you’re done to avoid memory leaks.**

---

## 🚀 Examples

### 1️⃣ Counter Example (Auto-managed)

```dart
// 1️⃣ Define the Model
class CounterModel {
  int count = 0;
}

// 2️⃣ Define an Event
class IncrementEvent implements Event<CounterModel> {
  @override
  void updateModel(CounterModel model, triggerEvent, _) {
    model.count++;
  }
}

// 3️⃣ Define the View
class CounterView extends StateView<CounterModel> {
  @override
  Widget view(BuildContext context, CounterModel state, triggerEvent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Count: ${state.count}', style: TextStyle(fontSize: 32)),
          ElevatedButton(
            onPressed: () => triggerEvent(IncrementEvent()),
            child: Text('Increment ➕'),
          ),
        ],
      ),
    );
  }
}

// 4️⃣ Wire up in main()
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Auto-managed Counter')),
      body: ModelProvider(
        CounterModel(),
        stateView: CounterView(),
      ),
    ),
  ));
}
```

---

### 2️⃣ Counter Example (Self-managed)

```dart
// Reuse CounterModel, IncrementEvent, CounterView from above

void main() {
  final counterController = ModelController(CounterModel());

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Self-managed Counter')),
      body: ModelProvider.controller(
        counterController,
        stateView: CounterView(),
      ),
    ),
  ));
}

```

---

### 3️⃣ Counter (Initial Events)

```dart
final provider = ModelProvider(
  CounterModel(),
  initialEvents: [IncrementEvent(), IncrementEvent()],
  stateView: CounterView(),
);
```

Immediately, the counter starts at 2!

---

### 4️⃣ Async Event Pattern ⏳

```dart
// 1️⃣ Model with loading/error state
class DataModel {
  bool isLoading = false;
  List<String>? items;
  String? error;
}

// 2️⃣ Define result events
class DataLoadedEvent implements Event<DataModel> {
  final List<String> items;
  DataLoadedEvent(this.items);

  @override
  void updateModel(DataModel model, _, __) {
    model.items = items;
    model.isLoading = false;
  }
}

class DataLoadFailedEvent implements Event<DataModel> {
  final String message;
  DataLoadFailedEvent(this.message);

  @override
  void updateModel(DataModel model, _, __) {
    model.error = message;
    model.isLoading = false;
  }
}

// 3️⃣ Async fetch event
class FetchDataEvent implements Event<DataModel> {
  @override
  void updateModel(DataModel model, triggerEvent, _) {
    model.isLoading = true;

    fetchRemoteItems()
      .then((items) => triggerEvent(DataLoadedEvent(items)))
      .catchError((err) => triggerEvent(DataLoadFailedEvent(err.toString())));
  }
}
```

---

Happy MVU‑ing! 🚀🎨✨