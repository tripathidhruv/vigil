import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import '../../models/notification_model.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsActionProvider);

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.notifications,
        hasCrisisActive: true,
        onTabSelected: (tab) => _nav(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.commandBlue.withOpacity(0.08),
          AppColors.intelViolet.withOpacity(0.06),
          AppColors.statusTeal.withOpacity(0.04),
        ],
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go('/dashboard'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderDefault)),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Notifications',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                TextButton(
                  onPressed: notifier.markAllRead,
                  child: const Text('Mark all read',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.commandBlue)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: notifsAsync.when(
                data: (notifs) => notifs.isEmpty
                    ? const Center(
                        child: Text('No notifications',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textMuted)))
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: notifs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final n = notifs[i];
                          return Dismissible(
                            key: ValueKey(n.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => notifier.dismiss(n.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.crisisRedDim,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: AppColors.crisisRed),
                            ),
                            child: GestureDetector(
                              onTap: () => notifier.markRead(n.id),
                              child: GlassCard(
                                borderColor: n.isRead
                                    ? AppColors.borderDefault
                                    : _typeColor(n.type).withOpacity(0.35),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      color: _typeColor(n.type)
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(_typeIcon(n.type),
                                        size: 18,
                                        color: _typeColor(n.type)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Row(children: [
                                        Expanded(
                                          child: Text(n.title,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: n.isRead
                                                    ? AppColors
                                                        .textSecondary
                                                    : AppColors
                                                        .textPrimary,
                                              )),
                                        ),
                                        if (!n.isRead)
                                          Container(
                                            width: 8, height: 8,
                                            decoration: BoxDecoration(
                                              color: _typeColor(n.type),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ]),
                                      const SizedBox(height: 3),
                                      Text(n.body,
                                          style: AppTypography.bodySmall
                                              .copyWith(height: 1.4)),
                                      const SizedBox(height: 5),
                                      Text(n.timeAgo,
                                          style: AppTypography.mono
                                              .copyWith(fontSize: 10)),
                                    ]),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.commandBlue)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Color _typeColor(NotifType t) => switch (t) {
        NotifType.crisis => AppColors.crisisRed,
        NotifType.staff => AppColors.statusTeal,
        NotifType.system => AppColors.intelViolet,
        NotifType.alert => AppColors.commandBlue,
      };

  IconData _typeIcon(NotifType t) => switch (t) {
        NotifType.crisis => Icons.warning_rounded,
        NotifType.staff => Icons.person_outline,
        NotifType.system => Icons.auto_awesome,
        NotifType.alert => Icons.campaign_outlined,
      };

  void _nav(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.dashboard:
        context.go('/dashboard');
      case VigilTab.warRoom:
        context.go('/war-room');
      case VigilTab.map:
        context.go('/floor-map');
      case VigilTab.notifications:
        break;
      case VigilTab.profile:
        context.go('/profile');
      case VigilTab.myTasks:
        context.go('/staff-home');
      case VigilTab.guestHome:
        context.go('/guest-home');
      default:
        break;
    }
  }
}
