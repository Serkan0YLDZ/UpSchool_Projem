import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/utils/calendar_date.dart';
import '../../core/widgets/brutalist_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/models/record_model.dart';
import '../../providers/completion_provider.dart';
import '../../providers/record_provider.dart';
import '../../providers/streak_provider.dart';
import '../home/visible_habits_for_date.dart';
import '../home/widgets/calendar_bar_widget.dart';
import '../home/widgets/event_card.dart';
import '../home/widgets/habit_card.dart';
import '../home/widgets/todo_card.dart';
import '../home/widgets/todo_filter_button.dart';
import 'focus_section.dart';

/// Yalnızca takvim, yalnızca alışkanlıklar veya yalnızca yapılacaklar.
class FocusSectionScreen extends StatefulWidget {
  const FocusSectionScreen({super.key, required this.section});
  final FocusSection section;
  @override
  State<FocusSectionScreen> createState() => _FocusSectionScreenState();
}

class _FocusSectionScreenState extends State<FocusSectionScreen> {
  bool _firstLoadDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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
    if (!mounted) return;
    setState(() => _firstLoadDone = true);
  }



  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RecordProvider>();
    final sp = context.watch<StreakProvider>();
    final todayYmd = CalendarDate.todayYmd();
    final visibleHabits = visibleHabitsForSelectedDate(rp, sp);
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
              if (!_firstLoadDone || rp.isLoading)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                )
              else if (rp.hasError)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: EmptyStateWidget(
                    icon: Icons.warning_amber_rounded,
                    message: rp.errorMessage ?? '',
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
  final List<RecordModel> visibleHabits;
  final String todayYmd;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecordProvider>();
    final track = context.track;

    switch (section) {
      case FocusSection.calendar:
        if (provider.scheduledTasks.isEmpty) {
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
        );

      case FocusSection.todos:
        if (provider.todos.isEmpty) {
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
                        (r) => TodoCard(
                          record: r,
                          selectedDate: provider.selectedDate,
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
