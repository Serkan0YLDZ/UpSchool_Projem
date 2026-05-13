import 'package:flutter_test/flutter_test.dart';
import 'package:my_new_habit/data/auth/auth_user.dart';
import 'package:my_new_habit/data/auth/mock_auth_backend.dart';

void main() {
  test('signInWithEmail should throw when email is empty', () async {
    final b = MockAuthBackend();
    expect(
      () => b.signInWithEmail(email: '  ', password: 'x'),
      throwsA(isA<StateError>()),
    );
  });

  test('signInWithEmail should throw when password is empty', () async {
    final b = MockAuthBackend();
    expect(
      () => b.signInWithEmail(email: 'a@b.com', password: ''),
      throwsA(isA<StateError>()),
    );
  });

  test('signInWithEmail should set currentUser after success', () async {
    final b = MockAuthBackend();
    await b.signInWithEmail(email: 'u@x.com', password: 'pw');
    expect(b.currentUser?.email, 'u@x.com');
    expect(b.currentUser?.uid, 'mock-uid-1');
    expect(b.currentUser?.method, AuthMethod.email);
  });

  test('signOut should clear currentUser', () async {
    final b = MockAuthBackend();
    await b.signInWithGoogle();
    expect(b.currentUser, isNotNull);
    await b.signOut();
    expect(b.currentUser, isNull);
  });
}
