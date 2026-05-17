import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/utils/calendar_date.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_badge.dart';
import 'package:track_calendar_tasks_habits/core/widgets/empty_state_widget.dart';

import 'package:track_calendar_tasks_habits/presentation/providers/calendar_event_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_day_log_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/home_state_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/streak_provider.dart';

import 'package:track_calendar_tasks_habits/presentation/screens/home/visible_habits_for_date.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/widgets/calendar_bar_widget.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/widgets/event_card.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/widgets/habit_card.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/widgets/todo_card.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/widgets/todo_filter_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  String? _errorMessage;

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
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final homeState = context.read<HomeStateProvider>();
      final selectedDate = homeState.selectedDate;
      final todayYmd = CalendarDate.todayYmd();

      final calendarProvider = context.read<CalendarEventProvider>();
      final habitProvider = context.read<HabitProvider>();
      final todoProvider = context.read<TodoProvider>();
      final logProvider = context.read<HabitDayLogProvider>();
      final streakProvider = context.read<StreakProvider>();

      await calendarProvider.loadEvents(selectedDate);
      await habitProvider.loadHabits();
      await todoProvider.loadTodos();
      
      final habits = habitProvider.habits;
      
      await logProvider.loadLogsForDate(selectedDate);
      await streakProvider.loadForHabits(habits, todayYmd);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Veriler yüklenirken bir hata oluştu.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_isLoading)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: EmptyStateWidget(
                    icon: Icons.warning_amber_rounded,
                    message: _errorMessage!,
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
    final homeState = context.watch<HomeStateProvider>();
    final calendarProvider = context.watch<CalendarEventProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final todoProvider = context.watch<TodoProvider>();
    final streakProvider = context.watch<StreakProvider>();

    final selectedDate = homeState.selectedDate;
    final todayYmd = CalendarDate.todayYmd();

    final visibleHabits = visibleHabitsForSelectedDate(
      habitProvider.habits,
      streakProvider,
      selectedDate,
    );

    final track = context.track;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TAKVİM BÖLÜMÜ (her zaman görünür) ---
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
          if (calendarProvider.events.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: AppSpacing.lg),
              child: Text(
                'Bu gün için etkinlik yok.',
                style: TextStyle(color: track.brutalistInk.withValues(alpha: 0.4), fontWeight: FontWeight.w600),
              ),
            )
          else ...[
            Stack(
              children: [
                Positioned(
                  left: 56,
                  top: 8,
                  bottom: 24,
                  child: Container(width: 4, color: track.brutalistInk),
                ),
                Column(
                  children: calendarProvider.events
                      .map(
                        (e) => EventCard(
                          event: e,
                          selectedDate: selectedDate,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          // --- ALIŞKANLIKLAR BÖLÜMÜ (her zaman görünür) ---
          BrutalistBadge(
            text: 'Alışkanlıklar',
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
          if (visibleHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: AppSpacing.xl),
              child: Text(
                'Bu gün için alışkanlık yok.',
                style: TextStyle(color: track.brutalistInk.withValues(alpha: 0.4), fontWeight: FontWeight.w600),
              ),
            )
          else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: visibleHabits
                  .map(
                    (h) => HabitCard(
                      habit: h,
                      selectedDate: selectedDate,
                      todayYmd: todayYmd,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          // --- YAPILACAKLAR BÖLÜMÜ (her zaman görünür) ---
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
          Builder(
            builder: (context) {
              final todos = todoProvider.todos;
              if (todos.isEmpty) return const SizedBox(height: AppSpacing.xl);
              return Column(
                children: todos
                    .map(
                      (t) => TodoCard(
                        todo: t,
                        selectedDate: selectedDate,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
