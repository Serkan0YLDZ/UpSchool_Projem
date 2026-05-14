enum AuthMethod { google, apple, email }

class AuthUser {
  const AuthUser({required this.uid, this.email, required this.method});

  final String uid;
  final String? email;
  final AuthMethod method;
}
