// Sprint 3: Ana Sayfa & Takvim — HomeScreen
// CustomScrollView+SliverList → ListView+Column (semantics crash fix)

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/calendar_date.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../providers/completion_provider.dart';
import '../../providers/record_provider.dart';
import '../../providers/streak_provider.dart';
import '../../core/widgets/brutalist_badge.dart';
import 'visible_habits_for_date.dart';
import 'widgets/calendar_bar_widget.dart';
import 'widgets/event_card.dart';
import 'widgets/habit_card.dart';
import 'widgets/todo_card.dart';
import 'widgets/todo_filter_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  Future<void> _onResume() async {
    if (!mounted) return;
    final recordProvider = context.read<RecordProvider>();
    final streakProvider = context.read<StreakProvider>();
    await recordProvider.loadRecords();
    if (!mounted) return;
    final todayYmd = CalendarDate.todayYmd();
    await streakProvider.loadForHabits(recordProvider.habits, todayYmd);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final recordProvider = context.read<RecordProvider>();
    final completionProvider = context.read<CompletionProvider>();
    final streakProvider = context.read<StreakProvider>();
    await recordProvider.loadRecords();
    if (!mounted) return;
    await completionProvider.loadForDate(recordProvider.selectedDate);
    if (!mounted) return;
    final todayYmd = CalendarDate.todayYmd();
    await streakProvider.loadForHabits(recordProvider.habits, todayYmd);
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
                const _ContentArea(),
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
  const _ContentArea();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecordProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final todayYmd = CalendarDate.todayYmd();
    final visibleHabits = visibleHabitsForSelectedDate(provider, streakProvider);

    final hasAny =
        provider.scheduledTasks.isNotEmpty ||
        visibleHabits.isNotEmpty ||
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
          if (visibleHabits.isNotEmpty) ...[
            const BrutalistBadge(
              text: 'Yeni Alışkanlıklar',
              backgroundColor: AppColors.sectionBannerYellow,
              textStyle: TextStyle(
                color: AppColors.onPrimary,
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
              children: visibleHabits
                  .map(
                    (r) => HabitCard(
                      record: r,
                      selectedDate: provider.selectedDate,
                      todayYmd: todayYmd,
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
                  backgroundColor: AppColors.sectionBannerPurple,
                  textStyle: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  rotatedOffset: -1.0,
                ),
                const TodoFilterButton(),
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
