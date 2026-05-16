import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/utils/calendar_date.dart';
import '../../core/widgets/brutalist_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../providers/completion_provider.dart';
import '../../providers/record_provider.dart';
import '../../providers/streak_provider.dart';
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
    if (state == AppLifecycleState.resumed) _onResume();
  }

  Future<void> _onResume() async {
    if (!mounted) return;
    final rp = context.read<RecordProvider>();
    final sp = context.read<StreakProvider>();
    await rp.loadRecords();
    if (!mounted) return;
    await sp.loadForHabits(rp.habits, CalendarDate.todayYmd());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final rp = context.read<RecordProvider>();
    final cp = context.read<CompletionProvider>();
    final sp = context.read<StreakProvider>();
    await rp.loadRecords();
    if (!mounted) return;
    await cp.loadForDate(rp.selectedDate);
    if (!mounted) return;
    await sp.loadForHabits(rp.habits, CalendarDate.todayYmd());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecordProvider>();
    final scheme = context.scheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: scheme.primary,
          onRefresh: _loadData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const CalendarBarWidget(),
              const SizedBox(height: AppSpacing.md),
              if (provider.isLoading)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                )
              else if (provider.hasError)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: EmptyStateWidget(
                    icon: Icons.warning_amber_rounded,
                    message: provider.errorMessage ?? '',
                    ctaLabel: 'Tekrar Dene',
                  ),
                )
              else
                const _ContentArea(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecordProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final todayYmd = CalendarDate.todayYmd();
    final visibleHabits = visibleHabitsForSelectedDate(provider, streakProvider);
    final track = context.track;

    final hasAny = provider.scheduledTasks.isNotEmpty ||
        visibleHabits.isNotEmpty ||
        provider.todos.isNotEmpty;

    if (!hasAny) {
      return const EmptyStateWidget(
        icon: Icons.auto_awesome,
        message: 'Bugün için kayıt yok.\nHaydi bir alışkanlık ekleyelim!',
        ctaLabel: 'Kayıt Ekle',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.scheduledTasks.isNotEmpty) ...[
            BrutalistBadge(
              text: 'Takvim',
              backgroundColor: AppColors.homeSectionCalendarBlue,
              borderRadius: AppSpacing.radiusLg,
              shadowOffset: 6,
              borderWidth: 2,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              rotatedOffset: -1.0,
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                Positioned(
                  left: 56,
                  top: 8,
                  bottom: 24,
                  child: Container(width: 4, color: track.brutalistInk),
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
          if (visibleHabits.isNotEmpty) ...[
            BrutalistBadge(
              text: 'Yeni Alışkanlıklar',
              backgroundColor: AppColors.homeSectionHabitsCoral,
              borderRadius: AppSpacing.radiusLg,
              shadowOffset: 6,
              borderWidth: 2,
              textStyle: const TextStyle(
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
          if (provider.todos.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BrutalistBadge(
                  text: 'Yapılacaklar',
                  backgroundColor: AppColors.homeSectionTodosOrange,
                  borderRadius: AppSpacing.radiusLg,
                  shadowOffset: 6,
                  borderWidth: 2,
                  textStyle: const TextStyle(
                    color: Colors.white,
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
                  todos =
                      todos.where((r) => compProvider.isDone(r.id)).toList();
                } else if (provider.activeFilters
                    .contains(FilterType.todoTodo)) {
                  todos =
                      todos.where((r) => !compProvider.isDone(r.id)).toList();
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
