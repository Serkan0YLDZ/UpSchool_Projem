import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/data/repositories/record_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('DB Insert Test', () async {
    WidgetsFlutterBinding.ensureInitialized();
    final dbHelper = DatabaseHelper.forTesting();
    final repo = SqfliteRecordRepository(dbHelper);
    
    final record = RecordModel(
      id: const Uuid().v4(),
      type: RecordType.quit,
      title: 'Sigara',
      createdAt: DateTime.now(),
    );
    
    try {
      await repo.create(record);
      print("SUCCESS");
    } catch (e, stack) {
      print("ERROR: \$e");
      print(stack);
    }
  });
}
