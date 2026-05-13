import 'package:flutter/foundation.dart';

/// Cursor debug oturumları için hafif log; üretimde sessiz.
void agentArchDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?>? data,
}) {
  assert(() {
    debugPrint('[agentArch][$hypothesisId] $location: $message ${data ?? {}}');
    return true;
  }());
}
