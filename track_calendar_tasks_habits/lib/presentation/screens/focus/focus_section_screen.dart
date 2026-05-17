import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/utils/calendar_date.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_badge.dart';
import 'package:track_calendar_tasks_habits/core/widgets/empty_state_widget.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
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
import 'package:track_calendar_tasks_habits/presentation/screens/focus/focus_section.dart';

/// Yalnızca takvim, yalnızca alışkanlıklar veya yalnızca yapılacaklar.
class FocusSectionScreen extends StatefulWidget {
  const FocusSectionScreen({super.key, required this.section});
  final FocusSection section;
  @override
  State<FocusSectionScreen> createState() => _FocusSectionScreenState();
}

class _FocusSectionScreenState extends State<FocusSectionScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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
    final homeState = context.watch<HomeStateProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final streakProvider = context.watch<StreakProvider>();
    
    final todayYmd = CalendarDate.todayYmd();
    final visibleHabits = visibleHabitsForSelectedDate(
      habitProvider.habits,
      streakProvider,
      homeState.selectedDate,
    );
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
                    message: _errorMessage ?? '',
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _SectionBody(
                    section: widget.section,
                    visibleHabits: visibleHabits,
                    todayYmd: todayYmd,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.visibleHabits,
    required this.todayYmd,
  });
  final FocusSection section;
  final List<HabitModel> visibleHabits;
  final String todayYmd;

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeStateProvider>();
    final calendarProvider = context.watch<CalendarEventProvider>();
    final todoProvider = context.watch<TodoProvider>();
    final track = context.track;

    switch (section) {
      case FocusSection.calendar:
        if (calendarProvider.events.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_today_rounded,
            message: 'Bu tarih için takvim etkinliği yok.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  children: calendarProvider.events
                      .map(
                        (e) => EventCard(
                          event: e,
                          selectedDate: homeState.selectedDate,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );

      case FocusSection.habits:
        if (visibleHabits.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.auto_awesome,
            message: 'Bu tarih için listelenecek alışkanlık yok.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      selectedDate: homeState.selectedDate,
                      todayYmd: todayYmd,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );

      case FocusSection.todos:
        if (todoProvider.todos.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.check_circle_outline_rounded,
            message: 'Yapılacak kayıt yok.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                var todos = todoProvider.todos;
                if (homeState.activeFilters.contains(FilterType.todoDone)) {
                  todos = todos.where((r) => r.isCompleted).toList();
                } else if (homeState.activeFilters.contains(FilterType.todoTodo)) {
                  todos = todos.where((r) => !r.isCompleted).toList();
                }
                if (todos.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg),
                    child: EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      message: 'Filtreye uygun yapılacak yok.',
                    ),
                  );
                }
                return Column(
                  children: todos
                      .map(
                        (t) => TodoCard(
                          todo: t,
                          selectedDate: homeState.selectedDate,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
    }
  }
}
