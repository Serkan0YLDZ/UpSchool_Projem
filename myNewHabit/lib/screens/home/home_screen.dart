// Sprint 3: Ana Sayfa & Takvim — HomeScreen
// CustomScrollView+SliverList → ListView+Column (semantics crash fix)

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../providers/completion_provider.dart';
import '../../providers/record_provider.dart';
import '../../core/widgets/brutalist_badge.dart';
import 'widgets/calendar_bar_widget.dart';
import 'widgets/event_card.dart';
import 'widgets/habit_card.dart';
import 'widgets/todo_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final recordProvider = context.read<RecordProvider>();
    final completionProvider = context.read<CompletionProvider>();
    await recordProvider.loadRecords();
    if (!mounted) return;
    await completionProvider.loadForDate(recordProvider.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    // context.watch yerine Consumer dışında okuma — tüm build() yeniden çalışır,
    // ama bu SliverList içi rebuild'dan çok daha güvenli.
    final provider = context.watch<RecordProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Takvim barı ─────────────────────────────────────────────
              const CalendarBarWidget(),
              const SizedBox(height: AppSpacing.md),

              // ── İçerik ──────────────────────────────────────────────────
              if (provider.isLoading)
                const _LoadingView()
              else if (provider.hasError)
                _ErrorView(message: provider.errorMessage ?? '')
              else
                _ContentArea(provider: provider),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: EmptyStateWidget(
        emoji: '⚠️',
        message: message,
        ctaLabel: 'Tekrar Dene',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.provider});
  final RecordProvider provider;

  @override
  Widget build(BuildContext context) {
    final hasAny =
        provider.scheduledTasks.isNotEmpty ||
        provider.habits.isNotEmpty ||
        provider.todos.isNotEmpty;

    if (!hasAny) {
      return const EmptyStateWidget(
        emoji: '🌟',
        message: 'Bugün için kayıt yok.\nHaydi bir alışkanlık ekleyelim!',
        ctaLabel: 'Kayıt Ekle',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Saatli Planlar ──────────────────────────────────────────────
          if (provider.scheduledTasks.isNotEmpty) ...[
            const BrutalistBadge(
              text: 'Takvim',
              backgroundColor: AppColors.primaryContainer,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              rotatedOffset: -1.0,
            ),
            const SizedBox(height: 24),
            // We use Stack to manage custom Timeline
            Stack(
              children: [
                Positioned(
                  left: 56, // About the visual alignment from the design
                  top: 8,
                  bottom: 24,
                  child: Container(width: 4, color: AppColors.brutalistBlack),
                ),
                Column(
                  children: provider.scheduledTasks
                      .map(
                        (r) => EventCard(
                          record: r,
                          selectedDate: provider.selectedDate,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Rutinlerim ──────────────────────────────────────────────────
          if (provider.habits.isNotEmpty) ...[
            const BrutalistBadge(
              text: 'Yeni Alışkanlıklar',
              backgroundColor: Color(0xFFE5B000), // Darker Yellow
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              rotatedOffset: -1.0,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: provider.habits
                  .map(
                    (r) => HabitCard(
                      record: r,
                      selectedDate: provider.selectedDate,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── Yapılacaklar ────────────────────────────────────────────────
          if (provider.todos.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BrutalistBadge(
                  text: 'Yapılacaklar',
                  backgroundColor: Color(0xFFAA44E0), // Darker Purple
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  rotatedOffset: -1.0,
                ),
                const _TodoFilterButton(),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Consumer<CompletionProvider>(
              builder: (context, compProvider, _) {
                var todos = provider.todos;
                if (provider.activeFilters.contains(FilterType.todoDone)) {
                  todos = todos
                      .where((r) => compProvider.isDone(r.id))
                      .toList();
                } else if (provider.activeFilters.contains(
                  FilterType.todoTodo,
                )) {
                  todos = todos
                      .where((r) => !compProvider.isDone(r.id))
                      .toList();
                }
                return Column(
                  children: todos
                      .map(
                        (r) => TodoCard(
                          record: r,
                          selectedDate: provider.selectedDate,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TodoFilterButton extends StatelessWidget {
  const _TodoFilterButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => _showFilterSheet(context, provider),
          child: Transform.rotate(
            angle: -2.0 * 3.1415 / 180,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brutalistWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brutalistBlack, width: 4.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.brutalistBlack,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                size: 24,
                color: AppColors.brutalistBlack,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, RecordProvider initialProvider) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer<RecordProvider>(
        builder: (consumerCtx, provider, _) => Container(
          decoration: const BoxDecoration(
            color: AppColors.brutalistWhite,
            border: Border(
              top: BorderSide(color: AppColors.brutalistBlack, width: 4),
              left: BorderSide(color: AppColors.brutalistBlack, width: 4),
              right: BorderSide(color: AppColors.brutalistBlack, width: 4),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YAPILACAKLARI FİLTRELE',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'DURUM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterOption(
                    label: 'Yapılanlar',
                    icon: Icons.check_circle_outline,
                    isSelected: provider.activeFilters.contains(FilterType.todoDone),
                    onTap: () => provider.toggleFilter(FilterType.todoDone),
                  ),
                  _FilterOption(
                    label: 'Yapılacaklar',
                    icon: Icons.pending_actions,
                    isSelected: provider.activeFilters.contains(FilterType.todoTodo),
                    onTap: () => provider.toggleFilter(FilterType.todoTodo),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'SIRALAMA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterOption(
                    label: 'En Önemli',
                    icon: Icons.star_border_rounded,
                    isSelected: provider.activeFilters.contains(FilterType.mostImportant),
                    onTap: () => provider.toggleFilter(FilterType.mostImportant),
                  ),
                  _FilterOption(
                    label: 'En Yakın Bitiş Tarihi',
                    icon: Icons.access_time_rounded,
                    isSelected: provider.activeFilters.contains(FilterType.earliest),
                    onTap: () => provider.toggleFilter(FilterType.earliest),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'ZAMAN ARALIĞI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterOption(
                    label: 'Bu Hafta',
                    icon: Icons.calendar_view_week_rounded,
                    isSelected: provider.activeFilters.contains(FilterType.thisWeek),
                    onTap: () => provider.toggleFilter(FilterType.thisWeek),
                  ),
                  _FilterOption(
                    label: 'Bu Ay',
                    icon: Icons.calendar_month_rounded,
                    isSelected: provider.activeFilters.contains(FilterType.thisMonth),
                    onTap: () => provider.toggleFilter(FilterType.thisMonth),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: isSelected ? const Offset(2, 2) : Offset.zero,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFAA44E0) : AppColors.brutalistWhite, // Purple matches Todo theme
            border: Border.all(color: AppColors.brutalistBlack, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? const []
                : const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: isSelected ? Colors.white : AppColors.brutalistBlack),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : AppColors.brutalistBlack,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
