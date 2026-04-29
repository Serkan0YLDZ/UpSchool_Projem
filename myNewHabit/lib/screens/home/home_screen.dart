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
import 'widgets/calendar_bar_widget.dart';
import 'widgets/filter_chip_bar.dart';
import 'widgets/habit_card.dart';
import 'widgets/quit_card.dart';
import 'widgets/task_card.dart';

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
              // ── Başlık ──────────────────────────────────────────────────
              const _HomeHeader(),

              // ── Takvim barı ─────────────────────────────────────────────
              const CalendarBarWidget(),
              const SizedBox(height: AppSpacing.sm),

              // ── Filtre chip barı ────────────────────────────────────────
              const FilterChipBar(),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMMM, EEEE', 'tr_TR').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merhaba 👋',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            today,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
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
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
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
    final hasAny = provider.scheduledTasks.isNotEmpty ||
        provider.habits.isNotEmpty ||
        provider.quitRecords.isNotEmpty;

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
            _SectionTitle(title: 'Takvim', emoji: '⏰'),
            const SizedBox(height: AppSpacing.sm),
            ...provider.scheduledTasks.map(
              (r) => TaskCard(record: r, selectedDate: provider.selectedDate),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Rutinlerim ──────────────────────────────────────────────────
          if (provider.habits.isNotEmpty) ...[
            _SectionTitle(title: 'Yeni Alışkanlıklarım', emoji: '🌿'),
            const SizedBox(height: AppSpacing.sm),
            ...provider.habits.map(
              (r) => HabitCard(record: r, selectedDate: provider.selectedDate),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Bırakılanlar ────────────────────────────────────────────────
          if (provider.quitRecords.isNotEmpty) ...[
            _SectionTitle(title: 'Bırakılanlar', emoji: '🚫'),
            const SizedBox(height: AppSpacing.sm),
            ...provider.quitRecords.map(
              (r) => QuitCard(record: r, selectedDate: provider.selectedDate),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.emoji});
  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
