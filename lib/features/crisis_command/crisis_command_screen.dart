import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/severity_pulse_badge.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/staff_chip.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import 'command_provider.dart';

class CrisisCommandScreen extends ConsumerWidget {
  const CrisisCommandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commandProvider);

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.warRoom,
        hasCrisisActive: !state.isAllClear,
        onTabSelected: (tab) => _nav(context, tab),
      ),
      body: AuroraBackground(
        blobColors: state.isAllClear
            ? [
                AppColors.safeGreen.withOpacity(0.10),
                AppColors.statusTeal.withOpacity(0.07),
                AppColors.commandBlue.withOpacity(0.05),
              ]
            : [
                AppColors.crisisRed.withOpacity(0.14),
                AppColors.alertOrange.withOpacity(0.07),
                AppColors.intelViolet.withOpacity(0.05),
              ],
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            // ── Top bar ────────────────────────────────────────────────────
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
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Crisis Command',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text('INC-${state.incidentId}',
                            style: AppTypography.mono
                                .copyWith(color: AppColors.crisisRed)),
                      ]),
                ),
                SeverityPulseBadge(severity: state.severity),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Timer card
                  GlassCard(
                    borderColor: state.isAllClear
                        ? AppColors.safeGreen.withOpacity(0.4)
                        : AppColors.glassRedBorder,
                    glowColor: state.isAllClear
                        ? AppColors.safeGreen
                        : AppColors.crisisRed,
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            state.isAllClear ? 'RESOLVED' : 'CRISIS ACTIVE',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: state.isAllClear
                                  ? AppColors.safeGreen
                                  : AppColors.crisisRed,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(state.title,
                              style: AppTypography.h2
                                  .copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(state.location,
                                style: AppTypography.bodySmall),
                          ]),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                        Text('ELAPSED',
                            style: AppTypography.label),
                        const SizedBox(height: 4),
                        Text(
                          state.timerFormatted,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: state.isAllClear
                                ? AppColors.safeGreen
                                : AppColors.crisisRed,
                            letterSpacing: -1,
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: state.isAllClear
                            ? null
                            : () {
                                HapticFeedback.heavyImpact();
                                ref
                                    .read(commandProvider.notifier)
                                    .declareAllClear();
                              },
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 14),
                          borderColor: state.isAllClear
                              ? AppColors.safeGreen.withOpacity(0.4)
                              : AppColors.glassRedBorder,
                          glowColor: state.isAllClear
                              ? AppColors.safeGreen
                              : null,
                          child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  state.isAllClear
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: state.isAllClear
                                      ? AppColors.safeGreen
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  state.isAllClear
                                      ? 'ALL CLEAR ✓'
                                      : 'DECLARE ALL CLEAR',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: state.isAllClear
                                        ? AppColors.safeGreen
                                        : AppColors.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/war-room'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 14),
                          borderColor:
                              AppColors.warningAmber.withOpacity(0.35),
                          child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.crisis_alert,
                                    color: AppColors.warningAmber,
                                    size: 20),
                                SizedBox(width: 8),
                                Text('WAR ROOM',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warningAmber,
                                      letterSpacing: 1,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/guest-alert'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 14),
                          borderColor:
                              AppColors.commandBlue.withOpacity(0.35),
                          child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.campaign_outlined,
                                    color: AppColors.commandBlue,
                                    size: 20),
                                SizedBox(width: 8),
                                Text('GUEST ALERT',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.commandBlue,
                                      letterSpacing: 1,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/floor-map'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 14),
                          borderColor:
                              AppColors.statusTeal.withOpacity(0.35),
                          child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined,
                                    color: AppColors.statusTeal,
                                    size: 20),
                                SizedBox(width: 8),
                                Text('FLOOR MAP',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.statusTeal,
                                      letterSpacing: 1,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 22),

                  // Assigned staff
                  Text('Assigned Staff', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  ...state.assignedStaff.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(children: [
                            StaffChip(
                                name: s.name,
                                role: s.role,
                                status: s.status),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: AppColors.bgElevated,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(s.task,
                                  style: AppTypography.bodySmall
                                      .copyWith(fontSize: 11)),
                            ),
                          ]),
                        ),
                      )),
                  const SizedBox(height: 22),

                  // Compliance shortcut
                  GlassCard(
                    borderColor:
                        AppColors.intelViolet.withOpacity(0.3),
                    glowColor: AppColors.intelViolet,
                    onTap: () => context.go('/compliance'),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                            color: AppColors.intelViolet.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.description_outlined,
                            size: 18, color: AppColors.intelViolet),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                            Text('Generate Compliance Report',
                                style: AppTypography.h3.copyWith(
                                    fontSize: 14)),
                            Text('AI-drafted, regulatory-ready in 60s',
                                style: AppTypography.bodySmall),
                          ])),
                      const Icon(Icons.chevron_right,
                          color: AppColors.intelViolet),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _nav(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.dashboard:
        context.go('/dashboard');
      case VigilTab.warRoom:
        break;
      case VigilTab.map:
        context.go('/floor-map');
      case VigilTab.notifications:
        context.go('/notifications');
      case VigilTab.profile:
        context.go('/profile');
    }
  }
}
