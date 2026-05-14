import 'dart:async';

import 'auth_backend.dart';
import 'auth_user.dart';

/// Gerçek ağ veya Firebase olmadan çalışan in-memory auth.
class MockAuthBackend implements AuthBackend {
  MockAuthBackend({this.demoUid = 'mock-uid-1'});

  final String demoUid;

  AuthUser? _user;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<AuthUser> signInWithGoogle() async =>
      _signIn(method: AuthMethod.google, email: 'kullanici@google.com');

  @override
  Future<AuthUser> signInWithApple() async =>
      _signIn(method: AuthMethod.apple, email: 'kullanici@icloud.com');

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw StateError('empty_credentials');
    }
    return _signIn(method: AuthMethod.email, email: email.trim());
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    _user = null;
    _controller.add(null);
  }

  Future<AuthUser> _signIn({
    required AuthMethod method,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _user = AuthUser(uid: demoUid, email: email, method: method);
    _controller.add(_user);
    return _user!;
  }
}
