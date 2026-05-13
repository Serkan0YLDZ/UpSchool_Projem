import 'package:flutter/material.dart';
import 'package:my_new_habit/core/utils/calendar_date.dart';
import 'package:provider/provider.dart';

import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/theme/app_spacing.dart';
import 'package:my_new_habit/core/widgets/brutalist_badge.dart';
import 'package:my_new_habit/core/widgets/empty_state_widget.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/providers/completion_provider.dart';
import 'package:my_new_habit/providers/record_provider.dart';
import 'package:my_new_habit/providers/streak_provider.dart';
import 'package:my_new_habit/screens/focus/focus_section.dart';
import 'package:my_new_habit/screens/home/visible_habits_for_date.dart';
import 'package:my_new_habit/screens/home/widgets/calendar_bar_widget.dart';
import 'package:my_new_habit/screens/home/widgets/event_card.dart';
import 'package:my_new_habit/screens/home/widgets/habit_card.dart';
import 'package:my_new_habit/screens/home/widgets/todo_card.dart';
import 'package:my_new_habit/screens/home/widgets/todo_filter_button.dart';

/// Ana sayfadan ayrı: yalnızca takvim etkinlikleri, yalnızca alışkanlıklar veya yalnızca yapılacaklar.
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
    final recordProvider = context.read<RecordProvider>();
    final completionProvider = context.read<CompletionProvider>();
    final streakProvider = context.read<StreakProvider>();
    await recordProvider.loadRecords();
    if (!mounted) return;
    await completionProvider.loadForDate(recordProvider.selectedDate);
    if (!mounted) return;
    final todayYmd = CalendarDate.todayYmd();
    await streakProvider.loadForHabits(recordProvider.habits, todayYmd);
    if (!mounted) return;
    setState(() => _firstLoadDone = true);
  }

  String get _title => switch (widget.section) {
        FocusSection.calendar => 'Takvim',
        FocusSection.habits => 'Alışkanlıklar',
        FocusSection.todos => 'Yapılacaklar',
      };

  @override
  Widget build(BuildContext context) {
    final recordProvider = context.watch<RecordProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final todayYmd = CalendarDate.todayYmd();
    final visibleHabits = visibleHabitsForSelectedDate(
      recordProvider,
      streakProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _title,
                    key: ValueKey('focus_section_title_${widget.section.name}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                    ),
                  ),
                ),
              ),
              const CalendarBarWidget(),
              const SizedBox(height: AppSpacing.md),
              if (!_firstLoadDone || recordProvider.isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (recordProvider.hasError)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: EmptyStateWidget(
                    emoji: '⚠️',
                    message: recordProvider.errorMessage ?? '',
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

    switch (section) {
      case FocusSection.calendar:
        if (provider.scheduledTasks.isEmpty) {
          return const EmptyStateWidget(
            emoji: '📅',
            message: 'Bu tarih için takvim etkinliği yok.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrutalistBadge(
              text: 'Takvim',
              backgroundColor: AppColors.primaryContainer,
              textStyle: TextStyle(
                color: AppColors.onPrimary,
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
            const SizedBox(height: AppSpacing.xl),
          ],
        );

      case FocusSection.habits:
        if (visibleHabits.isEmpty) {
          return const EmptyStateWidget(
            emoji: '🌟',
            message: 'Bu tarih için listelenecek alışkanlık yok.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        );

      case FocusSection.todos:
        if (provider.todos.isEmpty) {
          return const EmptyStateWidget(
            emoji: '✅',
            message: 'Yapılacak kayıt yok.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                if (todos.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg),
                    child: EmptyStateWidget(
                      emoji: '🔍',
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
