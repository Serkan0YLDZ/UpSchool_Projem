// Sprint V2: Firebase Authentication — Google, Apple, e-posta (kayıt = ilk giriş).

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_backend.dart';
import 'auth_user.dart';

class FirebaseAuthBackend implements AuthBackend {
  FirebaseAuthBackend({
    fb.FirebaseAuth? auth,
  }) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  @override
  AuthUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : _mapUser(u);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map((u) => u == null ? null : _mapUser(u));
  }

  AuthUser _mapUser(fb.User u) {
    return AuthUser(
      uid: u.uid,
      email: u.email,
      method: _methodForUser(u),
    );
  }

  AuthMethod _methodForUser(fb.User u) {
    for (final p in u.providerData) {
      if (p.providerId == 'google.com') {
        return AuthMethod.google;
      }
      if (p.providerId == 'apple.com') {
        return AuthMethod.apple;
      }
    }
    return AuthMethod.email;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw StateError('google_cancelled');
      }
      rethrow;
    }
    final ga = account.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      idToken: ga.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    final u = cred.user;
    if (u == null) {
      throw StateError('google_no_user');
    }
    return _mapUser(u);
  }

  @override
  Future<AuthUser> signInWithApple() async {
    final rawNonce = _randomNonce();
    final nonce = _sha256ofString(rawNonce);
    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final idToken = appleCred.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('apple_no_token');
    }
    final oauth = fb.OAuthProvider('apple.com');
    final credential = oauth.credential(
      idToken: idToken,
      rawNonce: rawNonce,
    );
    final cred = await _auth.signInWithCredential(credential);
    final u = cred.user;
    if (u == null) {
      throw StateError('apple_no_user');
    }
    return _mapUser(u);
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || password.isEmpty) {
      throw StateError('empty_credentials');
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmed,
        password: password,
      );
      final u = cred.user;
      if (u == null) {
        throw StateError('email_no_user');
      }
      return _mapUser(u);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: trimmed,
          password: password,
        );
        final u = cred.user;
        if (u == null) {
          throw StateError('email_create_failed');
        }
        return _mapUser(u);
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }

  static String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
