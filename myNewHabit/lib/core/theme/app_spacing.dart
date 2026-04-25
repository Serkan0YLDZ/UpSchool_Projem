// Sprint 1: Tasarım Sistemi — Spacing sabitleri (4px grid)
// Kural: EdgeInsets.all(16) gibi hardcode değer yazılmaz; AppSpacing kullanılır.

/// 4px grid'e dayalı spacing sabitleri.
///
/// Tasarım kaynağı: base=8px, xs=4px, sm=12px, md=24px, lg=40px, xl=64px
abstract final class AppSpacing {
  /// 4 dp — en küçük boşluk (ikon arası, chip padding)
  static const double xs = 4;

  /// 8 dp — küçük boşluk (satır arası, iç padding)
  static const double sm = 8;

  /// 12 dp — orta-küçük (buton iç padding dikey)
  static const double smMd = 12;

  /// 16 dp — standart iç padding (gutter)
  static const double md = 16;

  /// 20 dp — mobil kenar marjini
  static const double marginMobile = 20;

  /// 24 dp — kart iç padding
  static const double cardPadding = 24;

  /// 32 dp — section arası
  static const double lg = 32;

  /// 40 dp — büyük bölüm arası
  static const double xl = 40;

  /// 64 dp — ekran üst/alt boşluğu
  static const double xxl = 64;

  // ── Border radii ─────────────────────────────────────────────────────────
  /// 4 dp — en küçük radius
  static const double radiusXs = 4;

  /// 8 dp — küçük radius
  static const double radiusSm = 8;

  /// 12 dp — orta radius
  static const double radiusMd = 12;

  /// 16 dp — standart kart radius (rounded-lg)
  static const double radiusLg = 16;

  /// 24 dp — büyük kart radius (rounded-xl)
  static const double radiusXl = 24;

  /// 9999 dp — tam yuvarlak (pill shape)
  static const double radiusFull = 9999;

  // ── Touch targets ─────────────────────────────────────────────────────────
  /// Minimum dokunma hedefi yüksekliği
  static const double touchTarget = 48;

  /// Standart buton yüksekliği
  static const double buttonHeight = 56;
}
