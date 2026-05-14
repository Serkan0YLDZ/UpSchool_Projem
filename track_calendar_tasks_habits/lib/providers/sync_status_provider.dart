import 'package:flutter/foundation.dart';

/// Mock senkron durumu — backend entegrasyonu olmadığından her zaman "senkron" gösterir.
class SyncStatusProvider extends ChangeNotifier {
  bool _isBusy = false;
  bool _pendingSync = false;

  bool get isBusy => _isBusy;
  bool get isFullySynced => !_pendingSync;
  ({bool pendingSync}) get meta => (pendingSync: _pendingSync);

  Future<void> refresh() async {
    _isBusy = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isBusy = false;
    notifyListeners();
  }

  Future<void> syncNow() async {
    _isBusy = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _pendingSync = false;
    _isBusy = false;
    notifyListeners();
  }
}
