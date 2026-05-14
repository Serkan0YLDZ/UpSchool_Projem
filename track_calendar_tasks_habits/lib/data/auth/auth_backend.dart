import 'auth_user.dart';

/// Mock veya gerçek auth backend'ler için ortak sözleşme.
abstract class AuthBackend {
  AuthUser? get currentUser;
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithApple();
  Future<AuthUser> signInWithEmail({required String email, required String password});
  Future<void> signOut();
}
