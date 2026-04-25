# SOLID & OOP Principles

Follow these principles **without exception**. Every class, method, and module you write must demonstrate adherence to SOLID and core OOP principles.

---

## S — Single Responsibility Principle (SRP)

Every class has **one reason to change**.

- **UI widgets** are responsible only for rendering. They do not contain SQL queries, streak calculations, or notification scheduling.
- **Repositories** are responsible only for data access (CRUD). They do not format strings for the UI or calculate business logic.
- **Services** (`StreakService`, `NotificationService`) are responsible only for their named domain.
- **Providers** bridge the data layer and the UI. They hold state and expose it, but delegate all logic to Repositories/Services.

```dart
// ✅ Correct: Widget delegates to Provider
class HabitCard extends StatelessWidget {
  final RecordModel record;
  const HabitCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CompletionProvider>().markDone(record.id),
      child: _CardBody(record: record),
    );
  }
}

// ❌ Wrong: Widget queries the database directly
class HabitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper.instance;
    db.insert(...); // Never do this in a widget
    ...
  }
}
```

---

## O — Open/Closed Principle (OCP)

Classes are **open for extension, closed for modification**.

- Define abstract repository interfaces. Implementations can be swapped without touching callers.
- Add new record types or filter strategies by extending, not by adding `if/else` chains to existing classes.

```dart
// ✅ Correct: abstract contract
abstract class RecordRepository {
  Future<List<RecordModel>> getAll();
  Future<void> create(RecordModel record);
  Future<void> update(RecordModel record);
  Future<void> delete(String id);
}

class SqfliteRecordRepository implements RecordRepository { ... }
```

---

## L — Liskov Substitution Principle (LSP)

Any implementation of an interface must be fully substitutable for the abstract type. Do not override methods with no-ops or throw `UnimplementedError`.

---

## I — Interface Segregation Principle (ISP)

Do not force classes to depend on methods they don't use.

- Keep repository interfaces **narrow and focused**.
- `StreakService` should not have notification methods. `NotificationService` should not calculate streaks.

---

## D — Dependency Inversion Principle (DIP)

High-level modules (Providers, UI) must **not** depend on concrete low-level classes. Depend on abstractions.

- Inject repositories into Providers via the constructor. Do not instantiate `SqfliteRecordRepository()` inside a Provider directly.
- This enables future testability and swappability.

```dart
// ✅ Correct: Provider depends on abstraction
class RecordProvider extends ChangeNotifier {
  final RecordRepository _repository;
  RecordProvider(this._repository);
}

// ❌ Wrong: Provider is tightly coupled to implementation
class RecordProvider extends ChangeNotifier {
  final _repository = SqfliteRecordRepository(); // hard-coded
}
```

---

## Encapsulation

- All mutable state inside a Provider **must be private**.
- Expose state only through read-only `get` accessors.

```dart
class RecordProvider extends ChangeNotifier {
  List<RecordModel> _records = [];

  // ✅ Read-only exposure
  List<RecordModel> get records => List.unmodifiable(_records);

  Future<void> loadRecords(String date) async {
    _records = await _repository.getByDate(date);
    notifyListeners();
  }
}
```

---

## Composition Over Inheritance

- Build complex widgets by **composing** smaller widget classes.
- Only use `extends` for `StatelessWidget`, `StatefulWidget`, `ChangeNotifier`, and abstract repository interfaces.
- Never create deep inheritance chains for UI or business logic.
