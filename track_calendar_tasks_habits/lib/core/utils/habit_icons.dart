import 'package:flutter/material.dart';

/// Al\u0131\u015fkanl\u0131k kart\u0131 ikon & renk paleti.
///
/// \u0130konlar string-key ile saklan\u0131r; Flutter s\u00fcr\u00fcm de\u011fi\u015fikliklerinde
/// code point de\u011fi\u015febilece\u011fi i\u00e7in bu y\u00f6ntem daha g\u00fcvenlidir.
class HabitIcons {
  HabitIcons._();

  // ── \u0130kon katalogu ────────────────────────────────────────────────────────
  /// String-key \u2192 [IconData] e\u015fle\u015ftirmesi.
  static const Map<String, IconData> icons = {
    'water_drop': Icons.water_drop_rounded,
    'book':       Icons.menu_book_rounded,
    'run':        Icons.directions_run_rounded,
    'meditation': Icons.self_improvement_rounded,
    'star':       Icons.star_rounded,
    'fitness':    Icons.fitness_center_rounded,
    'target':     Icons.track_changes_rounded,
  };

  /// Varsay\u0131lan ikon anahtarı.
  static const String defaultKey = 'star';

  /// [key]'e kar\u015f\u0131l\u0131k gelen [IconData]'y\u0131 d\u00f6nd\u00fcr\u00fcr.
  /// Key bulunamazsa [Icons.star_rounded] d\u00f6ner.
  static IconData resolve(String? key) => icons[key] ?? Icons.star_rounded;

  // ── Renk paleti ──────────────────────────────────────────────────────────
  /// Se\u00e7ilebilir 7 renk (ARGB int de\u011ferleri).
  static const List<int> palette = [
    0xFFFF6B6B, // Coral
    0xFF4ECDC4, // Teal
    0xFFFFE66D, // Sar\u0131
    0xFFA8E063, // Ye\u015fil
    0xFFC39BD3, // Mor
    0xFFF7B731, // Turuncu
    0xFFFF8FAB, // Pembe
  ];

  /// Varsay\u0131lan ikon arka plan rengi (Turuncu).
  static const int defaultColor = 0xFFF7B731;

  /// Palette renk isimlerı (UI etiketleri için).
  static const List<String> paletteLabels = [
    'Coral', 'Teal', 'Sarı', 'Yeşil', 'Mor', 'Turuncu', 'Pembe',
  ];
}
