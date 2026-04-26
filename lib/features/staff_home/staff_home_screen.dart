import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import 'staff_provider.dart';
import '../auth/auth_provider.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final incidentsAsync = ref.watch(staffAssignedIncidentsProvider);
    
    // In our simplified model, tasks are incidents. Done = resolved.
    // For staff view, we only show active ones, so none are 'done'.
    // For staff view, we only show active ones, so none are 'done'.
    final total = incidentsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.myTasks,
        hasCrisisActive: false,
        onTabSelected: (tab) => _navTo(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.statusTeal.withOpacity(0.09),
          AppColors.commandBlue.withOpacity(0.06),
          AppColors.intelViolet.withOpacity(0.05),
        ],
        child: SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? 'Staff',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('${user?.role ?? 'Staff'} · On Duty',
                      style: AppTypography.bodySmall),
                ]),
                const Spacer(),
                // Panic button
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    // Panic action: create an SEV-1 incident
                    // using activation provider or firebase service.
                    // For now, just show the snackbar.
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.crisisRed,
                          content: Text('🚨 Panic alert sent to command!',
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.crisisRedDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.crisisRed.withOpacity(0.5)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_rounded,
                          size: 16, color: AppColors.crisisRed),
                      const SizedBox(width: 6),
                      const Text('PANIC',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.crisisRed,
                              letterSpacing: 1.5)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SlideUpReveal(
                delay: const Duration(milliseconds: 80),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: AppColors.statusTeal.withOpacity(0.3),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text('Assigned Incidents',
                          style: AppTypography.h3),
                      const Spacer(),
                      Text('$total active',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.statusTeal)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        value: 0.0,
                        minHeight: 4,
                        backgroundColor: AppColors.borderDefault,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.statusTeal),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active crisis banner
            if (total > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SlideUpReveal(
                  delay: const Duration(milliseconds: 120),
                  child: GestureDetector(
                    onTap: () => context.go('/crisis-command/${incidentsAsync.valueOrNull!.first.id}'),
                    child: GlassCard(
                      borderColor: AppColors.glassRedBorder,
                      glowColor: AppColors.crisisRed,
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.crisisRed, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              const Text('CRISIS ASSIGNED',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.crisisRed,
                                      letterSpacing: 1.5)),
                              const SizedBox(height: 2),
                              Text('${incidentsAsync.valueOrNull!.first.type} — ${incidentsAsync.valueOrNull!.first.location}',
                                  style: AppTypography.bodySmall),
                            ])),
                        const Icon(Icons.chevron_right,
                            color: AppColors.crisisRed),
                      ]),
                    ),
                  ),
                ),
              ),
            if (total > 0) const SizedBox(height: 20),

            // Task list
            Expanded(
              child: incidentsAsync.when(
                data: (list) => list.isEmpty
                    ? const Center(child: Text('No active assignments', style: TextStyle(color: AppColors.textMuted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final inc = list[i];
                          return SlideUpReveal(
                            delay: Duration(milliseconds: 160 + i * 55),
                            child: GestureDetector(
                              onTap: () => context.go('/crisis-command/${inc.id}'),
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                borderColor: AppColors.borderDefault,
                                child: Row(children: [
                                  GestureDetector(
                                    onTap: () async {
                                      HapticFeedback.lightImpact();
                                      await ref.read(staffActionProvider).markIncidentComplete(inc.id);
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          color: AppColors.borderDefault,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.check, size: 14, color: AppColors.textMuted),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(inc.type,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          )),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        const Icon(
                                            Icons.location_on_outlined,
                                            size: 12,
                                            color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(inc.location,
                                            style: AppTypography.bodySmall),
                                      ]),
                                    ]),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.statusTeal)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),


          ]),
        ),
      ),
    );
  }

  void _navTo(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.myTasks:
        break;
      case VigilTab.warRoom:
        context.go('/war-room');
      case VigilTab.map:
        context.go('/floor-map');
      case VigilTab.notifications:
        context.go('/notifications');
      case VigilTab.profile:
        context.go('/profile');
      default:
        break;
    }
  }
}
