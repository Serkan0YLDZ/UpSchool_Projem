// Debug session NDJSON (Cursor 983170) — şifre/token yazılmaz.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

const _kDebugLogPath = '/Users/serkan/Github/UpSchool_Projem/.cursor/debug-983170.log';
const _kSessionId = '983170';

/// Sadece hata ayıklama oturumu için; [kReleaseMode] içinde no-op.
void debugSessionLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'pre',
}) {
  if (kReleaseMode) return;
  try {
    final line = jsonEncode({
      'sessionId': _kSessionId,
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    File(_kDebugLogPath).writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
  } catch (_) {}
}

/// Çalışma dizini — Flutter'ın `ios/` altından mı yoksa proje kökünden mi başlatıldığını doğrular.
void debugSessionLogCwd({required String hypothesisId, String runId = 'pre'}) {
  if (kReleaseMode) return;
  try {
    debugSessionLog(
      hypothesisId: hypothesisId,
      location: 'debug_session_log.dart:cwd',
      message: 'cwd_snapshot',
      data: {'cwd': Directory.current.path},
      runId: runId,
    );
  } catch (_) {}
}
