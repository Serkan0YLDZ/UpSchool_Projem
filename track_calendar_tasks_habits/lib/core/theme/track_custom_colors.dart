import 'package:flutter/material.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';

/// ColorScheme dışı semantik renkler (brutalist çizgiler, seri, bantlar, öncelik).
@immutable
class TrackCustomColors extends ThemeExtension<TrackCustomColors> {
  const TrackCustomColors({
    required this.brutalistInk,
    required this.brutalistSurface,
    required this.neoStackFace,
    required this.neoStackShadow,
    required this.neoStackOnFace,
    required this.neoChromePlate,
    required this.streakFire,
    required this.streakRecovery,
    required this.streakMuted,
    required this.sectionBannerYellow,
    required this.sectionBannerPurple,
    required this.cardHeaderYellow,
    required this.neoBadgeDefaultYellow,
    required this.todoPriorityHigh,
    required this.todoPriorityMedium,
    required this.todoPriorityLow,
    required this.habitCardSoftBlue,
    required this.googleBrandBlue,
    required this.ambientShadow,
    required this.tertiaryFixed,
  });

  final Color brutalistInk;
  final Color brutalistSurface;
  final Color neoStackFace;
  final Color neoStackShadow;
  final Color neoStackOnFace;
  final Color neoChromePlate;
  final Color streakFire;
  final Color streakRecovery;
  final Color streakMuted;
  final Color sectionBannerYellow;
  final Color sectionBannerPurple;
  final Color cardHeaderYellow;
  final Color neoBadgeDefaultYellow;
  final Color todoPriorityHigh;
  final Color todoPriorityMedium;
  final Color todoPriorityLow;
  final Color habitCardSoftBlue;
  final Color googleBrandBlue;
  final Color ambientShadow;
  final Color tertiaryFixed;

  static TrackCustomColors of(BuildContext context) {
    return Theme.of(context).extension<TrackCustomColors>()!;
  }

  static const light = TrackCustomColors(
    brutalistInk: AppColors.brutalistBlack,
    brutalistSurface: AppColors.brutalistWhite,
    neoStackFace: AppColors.neoStackFace,
    neoStackShadow: AppColors.neoStackShadow,
    neoStackOnFace: AppColors.neoStackOnFace,
    neoChromePlate: AppColors.neoChromePlate,
    streakFire: AppColors.streakFire,
    streakRecovery: AppColors.streakRecovery,
    streakMuted: AppColors.streakMuted,
    sectionBannerYellow: AppColors.sectionBannerYellow,
    sectionBannerPurple: AppColors.sectionBannerPurple,
    cardHeaderYellow: AppColors.cardHeaderYellow,
    neoBadgeDefaultYellow: AppColors.neoBadgeDefaultYellow,
    todoPriorityHigh: AppColors.todoPriorityHigh,
    todoPriorityMedium: AppColors.todoPriorityMedium,
    todoPriorityLow: AppColors.todoPriorityLow,
    habitCardSoftBlue: AppColors.habitCardSoftBlue,
    googleBrandBlue: AppColors.googleBrandBlue,
    ambientShadow: AppColors.ambientShadow,
    tertiaryFixed: AppColors.tertiaryFixed,
  );

  @override
  TrackCustomColors copyWith({
    Color? brutalistInk,
    Color? brutalistSurface,
    Color? neoStackFace,
    Color? neoStackShadow,
    Color? neoStackOnFace,
    Color? neoChromePlate,
    Color? streakFire,
    Color? streakRecovery,
    Color? streakMuted,
    Color? sectionBannerYellow,
    Color? sectionBannerPurple,
    Color? cardHeaderYellow,
    Color? neoBadgeDefaultYellow,
    Color? todoPriorityHigh,
    Color? todoPriorityMedium,
    Color? todoPriorityLow,
    Color? habitCardSoftBlue,
    Color? googleBrandBlue,
    Color? ambientShadow,
    Color? tertiaryFixed,
  }) {
    return TrackCustomColors(
      brutalistInk: brutalistInk ?? this.brutalistInk,
      brutalistSurface: brutalistSurface ?? this.brutalistSurface,
      neoStackFace: neoStackFace ?? this.neoStackFace,
      neoStackShadow: neoStackShadow ?? this.neoStackShadow,
      neoStackOnFace: neoStackOnFace ?? this.neoStackOnFace,
      neoChromePlate: neoChromePlate ?? this.neoChromePlate,
      streakFire: streakFire ?? this.streakFire,
      streakRecovery: streakRecovery ?? this.streakRecovery,
      streakMuted: streakMuted ?? this.streakMuted,
      sectionBannerYellow: sectionBannerYellow ?? this.sectionBannerYellow,
      sectionBannerPurple: sectionBannerPurple ?? this.sectionBannerPurple,
      cardHeaderYellow: cardHeaderYellow ?? this.cardHeaderYellow,
      neoBadgeDefaultYellow:
          neoBadgeDefaultYellow ?? this.neoBadgeDefaultYellow,
      todoPriorityHigh: todoPriorityHigh ?? this.todoPriorityHigh,
      todoPriorityMedium: todoPriorityMedium ?? this.todoPriorityMedium,
      todoPriorityLow: todoPriorityLow ?? this.todoPriorityLow,
      habitCardSoftBlue: habitCardSoftBlue ?? this.habitCardSoftBlue,
      googleBrandBlue: googleBrandBlue ?? this.googleBrandBlue,
      ambientShadow: ambientShadow ?? this.ambientShadow,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
    );
  }

  @override
  TrackCustomColors lerp(ThemeExtension<TrackCustomColors>? other, double t) {
    if (other is! TrackCustomColors) return this;
    return TrackCustomColors(
      brutalistInk: Color.lerp(brutalistInk, other.brutalistInk, t)!,
      brutalistSurface:
          Color.lerp(brutalistSurface, other.brutalistSurface, t)!,
      neoStackFace: Color.lerp(neoStackFace, other.neoStackFace, t)!,
      neoStackShadow: Color.lerp(neoStackShadow, other.neoStackShadow, t)!,
      neoStackOnFace: Color.lerp(neoStackOnFace, other.neoStackOnFace, t)!,
      neoChromePlate: Color.lerp(neoChromePlate, other.neoChromePlate, t)!,
      streakFire: Color.lerp(streakFire, other.streakFire, t)!,
      streakRecovery: Color.lerp(streakRecovery, other.streakRecovery, t)!,
      streakMuted: Color.lerp(streakMuted, other.streakMuted, t)!,
      sectionBannerYellow:
          Color.lerp(sectionBannerYellow, other.sectionBannerYellow, t)!,
      sectionBannerPurple:
          Color.lerp(sectionBannerPurple, other.sectionBannerPurple, t)!,
      cardHeaderYellow:
          Color.lerp(cardHeaderYellow, other.cardHeaderYellow, t)!,
      neoBadgeDefaultYellow:
          Color.lerp(neoBadgeDefaultYellow, other.neoBadgeDefaultYellow, t)!,
      todoPriorityHigh:
          Color.lerp(todoPriorityHigh, other.todoPriorityHigh, t)!,
      todoPriorityMedium:
          Color.lerp(todoPriorityMedium, other.todoPriorityMedium, t)!,
      todoPriorityLow: Color.lerp(todoPriorityLow, other.todoPriorityLow, t)!,
      habitCardSoftBlue:
          Color.lerp(habitCardSoftBlue, other.habitCardSoftBlue, t)!,
      googleBrandBlue: Color.lerp(googleBrandBlue, other.googleBrandBlue, t)!,
      ambientShadow: Color.lerp(ambientShadow, other.ambientShadow, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
    );
  }
}

extension TrackThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;

  TrackCustomColors get track => TrackCustomColors.of(this);
}
