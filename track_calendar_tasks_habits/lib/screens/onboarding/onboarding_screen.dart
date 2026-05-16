import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/widgets/brutalist_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Hoş Geldin!',
      description: 'Takvim, alışkanlık ve görevlerini tek bir yerden yönetmeye hazır mısın?',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.homeSectionCalendarBlue,
    ),
    _OnboardingData(
      title: 'Hepsi Bir Arada',
      description: 'Takvim, Alışkanlıklar ve Yapılacaklar arasında kolayca geçiş yap. Sağ alttaki ikona çift dokunarak modları değiştirebilirsin.',
      icon: Icons.change_circle_rounded,
      color: AppColors.homeSectionHabitsCoral,
    ),
    _OnboardingData(
      title: 'Seriler ve Es Geç',
      description: 'Alışkanlıklarını takip et, serilerini bozma! Haftada bir kez "Es Geç" hakkını kullanarak serini koruyabilirsin.',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.homeSectionTodosOrange,
    ),
    _OnboardingData(
      title: 'Hazırsan Başlayalım',
      description: 'Verilerinin kaybolmaması ve tüm cihazlarında senkronize olması için Profil sayfasından giriş yapabilirsin.',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primaryContainer,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // Progress Indicator at TOP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? track.brutalistInk
                            : track.brutalistInk.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: track.brutalistInk, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Symbolic UI Representation
                          _buildMockUI(index, data.color),
                          const SizedBox(height: 40),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineMd.copyWith(
                              color: track.brutalistInk,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            data.description,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLg.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer area with Brutalist Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: BrutalistContainer(
                onTap: () {
                  if (_currentIndex == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                backgroundColor: _pages[_currentIndex].color,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: Text(
                    _currentIndex == _pages.length - 1 ? 'HADİ BAŞLAYALIM!' : 'DEVAM ET',
                    style: AppTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockUI(int index, Color color) {
    final track = context.track;
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: track.brutalistInk.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Center(
        child: switch (index) {
          0 => BrutalistContainer(
              width: 120,
              height: 120,
              backgroundColor: color,
              rotatedOffset: -3,
              child: const Icon(Icons.track_changes_rounded, size: 60, color: Colors.white),
            ),
          1 => Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 20,
                  child: _miniCard(Icons.calendar_month_rounded, AppColors.homeSectionCalendarBlue, 5),
                ),
                Positioned(
                  bottom: 20,
                  left: 60,
                  child: _miniCard(Icons.repeat_rounded, AppColors.homeSectionHabitsCoral, -5),
                ),
                Positioned(
                  bottom: 20,
                  right: 60,
                  child: _miniCard(Icons.check_circle_outline_rounded, AppColors.homeSectionTodosOrange, 2),
                ),
              ],
            ),
          2 => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _miniCard(Icons.local_fire_department_rounded, i < 3 ? color : Colors.grey.shade300, 0, size: 40),
                  )),
                ),
                const SizedBox(height: 20),
                Text('3 Günlük Seri!', style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          _ => BrutalistContainer(
              width: 140,
              height: 100,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch_rounded, size: 40),
                  const SizedBox(height: 8),
                  Container(height: 8, width: 60, color: color),
                ],
              ),
            ),
        },
      ),
    );
  }

  Widget _miniCard(IconData icon, Color color, double rotation, {double size = 50}) {
    return Transform.rotate(
      angle: rotation * 3.14 / 180,
      child: BrutalistContainer(
        width: size,
        height: size,
        backgroundColor: color,
        padding: EdgeInsets.zero,
        borderRadius: AppSpacing.radiusMd,
        borderWidth: 2,
        shadowOffset: 3,
        child: Icon(icon, size: size * 0.6, color: Colors.white),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
