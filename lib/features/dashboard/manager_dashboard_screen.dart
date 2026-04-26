import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/count_up_number.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/incident_card.dart';
import '../../core/widgets/staff_chip.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import 'dashboard_provider.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(hotelStatsProvider);
    final incidents = ref.watch(incidentListProvider);
    final staff = ref.watch(staffListProvider);
    final now = DateTime.now();

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.dashboard,
        hasCrisisActive: stats.hasCrisis,
        onTabSelected: (tab) => _navTo(context, tab),
      ),
      body: AuroraBackground(
        blobColors: stats.hasCrisis
            ? [
                AppColors.crisisRed.withOpacity(0.10),
                AppColors.intelViolet.withOpacity(0.06),
                AppColors.commandBlue.withOpacity(0.04),
              ]
            : [
                AppColors.statusTeal.withOpacity(0.08),
                AppColors.commandBlue.withOpacity(0.06),
                AppColors.intelViolet.withOpacity(0.04),
              ],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grand Hyatt Mumbai',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Text(DateFormat('EEEE, d MMM').format(now),
                              style: AppTypography.bodySmall),
                          const SizedBox(width: 8),
                          Container(
                              width: 1, height: 10, color: AppColors.borderDefault),
                          const SizedBox(width: 8),
                          Text(DateFormat('HH:mm').format(now),
                              style: AppTypography.mono
                                  .copyWith(color: AppColors.statusTeal)),
                        ]),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go('/notifications'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AppColors.borderDefault),
                        ),
                        child: Stack(alignment: Alignment.center, children: [
                          const Icon(Icons.notifications_outlined, size: 20),
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                  color: AppColors.crisisRed,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Scrollable body ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crisis banner
                      if (stats.hasCrisis)
                        SlideUpReveal(
                          delay: const Duration(milliseconds: 40),
                          child: GestureDetector(
                            onTap: () => context.go('/crisis-command'),
                            child: GlassCard(
                              borderColor: AppColors.glassRedBorder,
                              glowColor: AppColors.crisisRed,
                              padding: const EdgeInsets.all(14),
                              child: Row(children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.crisisRedDim,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: AppColors.crisisRed, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('ACTIVE CRISIS',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.crisisRed,
                                              letterSpacing: 1.5,
                                            )),
                                        const SizedBox(height: 2),
                                        Text(
                                            'Kitchen fire · 4 staff assigned',
                                            style: AppTypography.bodySmall),
                                      ]),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.crisisRed),
                              ]),
                            ),
                          ),
                        ),
                      if (stats.hasCrisis) const SizedBox(height: 14),

                      // Stats row
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 80),
                        child: Row(
                          children: [
                            _Stat('ACTIVE', stats.activeIncidents,
                                AppColors.crisisRed, Icons.warning_amber_rounded),
                            const SizedBox(width: 10),
                            _Stat('ON DUTY', stats.staffOnDuty,
                                AppColors.statusTeal, Icons.people_outline),
                            const SizedBox(width: 10),
                            _Stat('RESOLVED', stats.resolvedToday,
                                AppColors.safeGreen, Icons.check_circle_outline),
                            const SizedBox(width: 10),
                            _Stat('AVG MIN', stats.avgResponseMin,
                                AppColors.commandBlue, Icons.timer_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Quick actions
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 130),
                        child: Row(children: [
                          _Action('Report\nIncident', Icons.add_alert_outlined,
                              AppColors.crisisRed,
                              () => context.go('/crisis-activation')),
                          const SizedBox(width: 10),
                          _Action('War\nRoom', Icons.crisis_alert,
                              AppColors.warningAmber,
                              () => context.go('/war-room')),
                          const SizedBox(width: 10),
                          _Action('Floor\nMap', Icons.map_outlined,
                              AppColors.statusTeal,
                              () => context.go('/floor-map')),
                          const SizedBox(width: 10),
                          _Action('Run\nDrill', Icons.sports_martial_arts,
                              AppColors.intelViolet,
                              () => context.go('/drill')),
                        ]),
                      ),
                      const SizedBox(height: 22),

                      // Incidents header
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 180),
                        child: Row(children: [
                          Text('Active Incidents', style: AppTypography.h3),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See all',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.commandBlue)),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      ...incidents.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SlideUpReveal(
                              delay: Duration(
                                  milliseconds: 200 + e.key * 60),
                              child: IncidentCard(
                                incident: e.value,
                                onTap: () =>
                                    context.go('/crisis-command'),
                              ),
                            ),
                          )),
                      const SizedBox(height: 22),

                      // Staff
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 380),
                        child: Text('Staff On Duty', style: AppTypography.h3),
                      ),
                      const SizedBox(height: 10),
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 420),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: staff
                                .map((s) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10),
                                      child: StaffChip(
                                          name: s.name,
                                          role: s.role,
                                          status: s.status),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Gemini insight
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 460),
                        child: GlassCard(
                          borderColor:
                              AppColors.intelViolet.withOpacity(0.35),
                          glowColor: AppColors.intelViolet,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.intelViolet.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.auto_awesome,
                                    size: 18, color: AppColors.intelViolet),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('GEMINI INSIGHT',
                                          style: AppTypography.label.copyWith(
                                              color: AppColors.intelViolet)),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Kitchen incidents +40% this week. '
                                        'Schedule a Fire Safety drill. '
                                        'Response time within SLA at 4 min avg.',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            height: 1.55),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navTo(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.dashboard:
        break;
      case VigilTab.warRoom:
        context.go('/war-room');
      case VigilTab.map:
        context.go('/floor-map');
      case VigilTab.notifications:
        context.go('/notifications');
      case VigilTab.profile:
        context.go('/profile');
    }
  }
}

// ── Local helper widgets ──────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _Stat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          borderColor: color.withOpacity(0.22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 8),
            CountUpNumber(
                end: value,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted)),
          ]),
        ),
      );
}

class _Action extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Action(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: GlassCard(
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            borderColor: color.withOpacity(0.22),
            child: Column(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.3)),
            ]),
          ),
        ),
      );
}
