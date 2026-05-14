import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth/auth_backend.dart';
import '../data/auth/auth_user.dart';

export '../data/auth/auth_user.dart' show AuthMethod;

/// Statik mock kullanıcıyla başlayan auth session — gerçek oturum akışlarını simüle eder.
class AuthSessionProvider extends ChangeNotifier {
  AuthSessionProvider({required AuthBackend backend}) : _backend = backend {
    _user = _backend.currentUser;
    _authSub = _backend.authStateChanges().listen(_onAuthUser);
  }

  final AuthBackend _backend;
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
    _user = user;
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
    await _guard(() => _backend.signInWithEmail(email: email, password: password));
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
      _errorMessage = _mapError(e);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _mapError(Object e) {
    if (e is StateError) {
      return switch (e.message) {
        'empty_credentials' => 'E-posta ve şifre gerekli.',
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
