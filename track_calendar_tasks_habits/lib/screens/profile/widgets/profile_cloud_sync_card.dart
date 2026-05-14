import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../core/widgets/brutalist_container.dart';
import '../../../providers/auth_session_provider.dart';
import '../../../providers/sync_status_provider.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulut senkron',
            style: AppTypography.headlineSm.copyWith(fontSize: 18),
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
                      ? 'Verilerin buluttaki veritabanı ile senkron.'
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
          SizedBox(
            height: AppSpacing.buttonHeight,
            width: double.infinity,
            child: FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (synced) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Verilerin zaten buluttaki veritabanı ile senkron.',
                            ),
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
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Senkron hatası: $e')),
                        );
                      }
                    },
              child: Text(
                synced ? 'Senkron (bilgi)' : 'Senkron et',
                style: AppTypography.labelLg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
