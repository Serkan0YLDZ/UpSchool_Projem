// Sprint 2: Test stub — RecordRepository manuel implementasyonu
//
// Neden stub? Provider testlerinde gerçek sqflite DB bağlantısı açmak
// gerekmiyor. Stub ile bağımlılık izole edilir; testler hızlı ve bağımsız çalışır.

import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/data/repositories/record_repository.dart';

/// RecordRepository'nin test için basit in-memory implementasyonu.
class StubRecordRepository implements RecordRepository {
  List<RecordModel> recordsToReturn = [];
  final List<RecordModel> created = [];
  final List<String> deletedIds = [];
  bool shouldThrow = false;
  String? lastQueriedDate;

  @override
  Future<List<RecordModel>> getAll() async {
    if (shouldThrow) throw Exception('stub error');
    return List.from(recordsToReturn);
  }

  @override
  Future<List<RecordModel>> getByDate(String date) async {
    lastQueriedDate = date;
    if (shouldThrow) throw Exception('stub error');
    return List.from(recordsToReturn);
  }

  @override
  Future<void> create(RecordModel record) async {
    created.add(record);
    recordsToReturn.add(record);
  }

  @override
  Future<void> update(RecordModel record) async {
    final index = recordsToReturn.indexWhere((r) => r.id == record.id);
    if (index != -1) recordsToReturn[index] = record;
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
    recordsToReturn.removeWhere((r) => r.id == id);
  }

  @override
  Future<RecordModel?> getById(String id) async {
    try {
      return recordsToReturn.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
