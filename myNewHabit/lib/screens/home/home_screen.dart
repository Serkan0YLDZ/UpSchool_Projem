// Sprint 3: Ana Sayfa & Takvim — HomeScreen
// CustomScrollView+SliverList → ListView+Column (semantics crash fix)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer<RecordProvider>(
        builder: (consumerCtx, provider, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yapılacakları Filtrele',
                    style: Theme.of(consumerCtx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Durum',
                    style: Theme.of(consumerCtx).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterOption(
                    label: 'Yapılanlar',
                    icon: '✅',
                    isSelected: provider.activeFilters.contains(
                      FilterType.todoDone,
                    ),
                    onTap: () {
                      provider.toggleFilter(FilterType.todoDone);
                    },
                  ),
                  _FilterOption(
                    label: 'Yapılacaklar',
                    icon: '🔄',
                    isSelected: provider.activeFilters.contains(
                      FilterType.todoTodo,
                    ),
                    onTap: () {
                      provider.toggleFilter(FilterType.todoTodo);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Sıralama',
                    style: Theme.of(consumerCtx).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterOption(
                    label: 'En Önemli',
                    icon: '⭐',
                    isSelected: provider.activeFilters.contains(
                      FilterType.mostImportant,
                    ),
                    onTap: () {
                      provider.toggleFilter(FilterType.mostImportant);
                    },
                  ),
                  _FilterOption(
                    label: 'En Yakın Bitiş Tarihi',
                    icon: '⏰',
                    isSelected: provider.activeFilters.contains(
                      FilterType.earliest,
                    ),
                    onTap: () {
                      provider.toggleFilter(FilterType.earliest);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Zaman Aralığı',
                    style: Theme.of(consumerCtx).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterOption(
                    label: 'Bu Hafta',
                    icon: '📅',
                    isSelected: provider.activeFilters.contains(
                      FilterType.thisWeek,
                    ),
                    onTap: () {
                      provider.toggleFilter(FilterType.thisWeek);
                    },
                  ),
                  _FilterOption(
                    label: 'Bu Ay',
                    icon: '🗓',
                    isSelected: provider.activeFilters.contains(
                      FilterType.thisMonth,
                    ),
                    onTap: () {
                      provider.toggleFilter(FilterType.thisMonth);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
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
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
