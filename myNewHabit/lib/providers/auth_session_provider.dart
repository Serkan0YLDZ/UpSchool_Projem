// Sprint V2: Firebase Auth (veya mock) oturumu — girişte misafir verisini senkron kuyruğuna alır.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/utils/debug_session_log.dart';
import '../data/auth/auth_backend.dart';
import '../data/auth/auth_user.dart';
import '../data/database/database_helper.dart';

export '../data/auth/auth_user.dart' show AuthMethod;

/// Oturum durumu; [AuthBackend] ile soyutlanır (testte mock).
class AuthSessionProvider extends ChangeNotifier {
  AuthSessionProvider({
    required AuthBackend backend,
    DatabaseHelper? dbHelper,
  })  : _backend = backend,
        _dbHelper = dbHelper {
    _user = _backend.currentUser;
    _authSub = _backend.authStateChanges().listen(_onAuthUser);
  }

  final AuthBackend _backend;
  final DatabaseHelper? _dbHelper;
  StreamSubscription<AuthUser?>? _authSub;

  AuthUser? _user;
  bool _isBusy = false;
  String? _errorMessage;

  bool get isAuthenticated => _user != null;
  String? get email => _user?.email;
  AuthMethod? get method => _user?.method;
  String? get uid => _user?.uid;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _onAuthUser(AuthUser? user) {
    final signedIn = _user == null && user != null;
    _user = user;
    if (signedIn) {
      final db = _dbHelper;
      if (db != null) {
        unawaited(db.markSyncDirtyIfHasRecords());
      }
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _guard(() => _backend.signInWithGoogle());
  }

  Future<void> signInWithApple() async {
    await _guard(() => _backend.signInWithApple());
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _guard(
      () => _backend.signInWithEmail(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    if (_isBusy) return;
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _backend.signOut();
    } catch (e) {
      _errorMessage = _mapError(e);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _guard(Future<AuthUser> Function() op) async {
    if (_isBusy) return;
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await op();
    } catch (e) {
      // #region agent log
      debugSessionLog(
        hypothesisId: 'H2',
        location: 'auth_session_provider.dart:_guard',
        message: 'sign_in_failed',
        data: {
          'type': e.runtimeType.toString(),
          if (e is fb.FirebaseAuthException) 'code': e.code,
        },
      );
      // #endregion
      _errorMessage = _mapError(e);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _mapError(Object e) {
    if (e is fb.FirebaseAuthException) {
      return switch (e.code) {
        'wrong-password' => 'Şifre hatalı.',
        'invalid-email' => 'Geçersiz e-posta.',
        'user-disabled' => 'Bu hesap devre dışı.',
        'weak-password' => 'Şifre çok zayıf (en az 6 karakter).',
        'email-already-in-use' => 'Bu e-posta zaten kayıtlı.',
        'network-request-failed' => 'Ağ hatası. Bağlantını kontrol et.',
        _ => 'Giriş yapılamadı: ${e.message ?? e.code}',
      };
    }
    if (e is GoogleSignInException) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'Google girişi iptal edildi.';
      }
      return 'Google girişi başarısız.';
    }
    if (e is StateError) {
      return switch (e.message) {
        'google_cancelled' => 'Google girişi iptal edildi.',
        'empty_credentials' => 'E-posta ve şifre gerekli.',
        'apple_no_token' => 'Apple kimliği alınamadı.',
        'google_no_user' => 'Google hesabı doğrulanamadı.',
        _ => 'Giriş tamamlanamadı.',
      };
    }
    return 'Beklenmeyen hata: $e';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
