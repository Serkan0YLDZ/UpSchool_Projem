import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_colors.dart';

/// Ana navigasyon kabuğu.
///
/// 3 tab: 🏠 Ana Sayfa · ➕ Ekle · 👤 Profil
/// "Ekle" sekmesi doğrudan bir sayfa değil; bottom sheet açar.
/// Bu nedenle ShellRoute içindeki sadece 2 sayfa rotaya kayıtlıdır.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      extendBody: true, // Body'nin navigation bar arkasına uzaması için
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onNavTap(context, index),
      ),
    );
  }

  // "Ekle" (index 1) tıklandığında bottom sheet açılır; rota değişmez.
  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        // Sprint 2'de AddRecordModal burada açılacak
        _showAddPlaceholder(context);
      case 2:
        context.go(AppRoutes.profile);
    }
  }

  void _showAddPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt ekleme — Sprint 2\'de gelecek!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.profile)) return 2;
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    // Tasarımdaki w-3/5 (genişliğin %60'ı) max-w-xs (320px) özelliğini sağlıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final width = (screenWidth * 0.6).clamp(0.0, 320.0);

    return Container(
      width: width,
      height: 64, // p-3 ve icon boyutlarına uygun sabit yükseklik
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withAlpha(38), // rgba(255,140,0,0.15) yerine ana renkten 15% shadow
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            isSelected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.add_rounded,
            isSelected: selectedIndex == 1,
            iconSize: 28, // HTML'de "text-[28px]" kullanılmıştı
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            isSelected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.iconSize = 24,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade500,
          size: iconSize,
        ),
      ),
    );
  }
}
