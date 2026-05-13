// Sprint V2: Kimlik sağlayıcı soyutlaması — testlerde mock, üretimde Firebase.

import 'auth_user.dart';

/// Firebase veya sahte backend için ortak sözleşme.
abstract class AuthBackend {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithApple();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
