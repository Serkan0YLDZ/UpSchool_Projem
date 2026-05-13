// Sprint V2: Oturum kullanıcısı — Firebase veya mock backend ortak modeli.

/// Giriş kanalı (profil etiketi için).
enum AuthMethod {
  google,
  apple,
  email,
}

/// Kimlik doğrulama sonrası uygulama içi kullanıcı özeti.
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    required this.method,
  });

  final String uid;
  final String? email;
  final AuthMethod method;
}
