import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_typography.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_container.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/auth_session_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/sync_status_provider.dart';

class ProfileCloudSyncCard extends StatefulWidget {
  const ProfileCloudSyncCard({super.key});

  @override
  State<ProfileCloudSyncCard> createState() => _ProfileCloudSyncCardState();
}

class _ProfileCloudSyncCardState extends State<ProfileCloudSyncCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<SyncStatusProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionProvider>();
    final sync = context.watch<SyncStatusProvider>();
    final synced = sync.isFullySynced;
    final busy = sync.isBusy || auth.isBusy;
    final scheme = context.scheme;

    return BrutalistContainer(
      rotatedOffset: -0.35,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulut senkron',
            style: AppTypography.headlineSm.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                synced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                color: synced
                    ? scheme.primaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  synced
                      ? 'Verilerin buluttaki veritabanı ile senkronize edildi.'
                      : (sync.meta.pendingSync
                          ? 'Yerel değişiklikler henüz buluta tam yansımadı.'
                          : 'Henüz tam senkron yapılmadı. Aşağıdaki düğmeyi kullan.'),
                  style: AppTypography.bodyMd.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BrutalistContainer(
            onTap: busy
                ? null
                : () async {
                    if (synced) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Verilerin zaten buluttaki veritabanı ile senkronize.',
                          ),
                          backgroundColor: context.track.brutalistInk,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    try {
                      await sync.syncNow();
                      if (!context.mounted) return;
                      await sync.refresh();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            sync.isFullySynced
                                ? 'Senkron tamamlandı.'
                                : 'Senkron tamamlanamadı; bağlantını kontrol et.',
                          ),
                          backgroundColor: context.track.brutalistInk,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Senkron hatası: $e'),
                          backgroundColor: context.track.brutalistInk,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            backgroundColor: synced ? scheme.primaryContainer.withAlpha(200) : scheme.primaryContainer,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Text(
                synced ? 'SENKRONİZE EDİLDİ' : 'ŞİMDİ SENKRON ET',
                style: AppTypography.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
