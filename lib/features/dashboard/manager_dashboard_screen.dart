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
import '../notifications/notifications_provider.dart';
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
        hasCrisisActive: stats.valueOrNull?.hasCrisis ?? false,
        onTabSelected: (tab) => _navTo(context, tab),
      ),
      body: AuroraBackground(
        blobColors: (stats.valueOrNull?.hasCrisis ?? false)
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
                        child: Consumer(
                          builder: (context, ref, child) {
                            final unreadCount = ref.watch(unreadNotificationsCountProvider);
                            final hasUnread = unreadCount > 0;
                            return Stack(alignment: Alignment.center, children: [
                              const Icon(Icons.notifications_outlined, size: 20),
                              if (hasUnread)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    width: 7, height: 7,
                                    decoration: const BoxDecoration(
                                        color: AppColors.crisisRed,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                            ]);
                          },
                        ),
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
                      if (stats.valueOrNull?.hasCrisis ?? false)
                        SlideUpReveal(
                          delay: const Duration(milliseconds: 40),
                          child: GestureDetector(
                            onTap: () {
                              final activeIncident = incidents.valueOrNull?.firstWhere((i) => i.isActive);
                              if (activeIncident != null) {
                                context.go('/crisis-command/${activeIncident.id}');
                              }
                            },
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
                                            '${incidents.valueOrNull?.firstWhere((i) => i.isActive).type ?? "Emergency"} · ${incidents.valueOrNull?.firstWhere((i) => i.isActive).assignedTo.length ?? 0} staff assigned',
                                            style: AppTypography.bodySmall),
                                      ]),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.crisisRed),
                              ]),
                            ),
                          ),
                        ),
                      if (stats.valueOrNull?.hasCrisis ?? false) const SizedBox(height: 14),

                      // Stats row
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 80),
                        child: Row(
                          children: [
                            _Stat('ACTIVE', stats.valueOrNull?.activeIncidents ?? 0,
                                AppColors.crisisRed, Icons.warning_amber_rounded),
                            const SizedBox(width: 10),
                            _Stat('ON DUTY', stats.valueOrNull?.staffOnDuty ?? 0,
                                AppColors.statusTeal, Icons.people_outline),
                            const SizedBox(width: 10),
                            _Stat('RESOLVED', stats.valueOrNull?.resolvedToday ?? 0,
                                AppColors.safeGreen, Icons.check_circle_outline),
                            const SizedBox(width: 10),
                            _Stat('AVG MIN', stats.valueOrNull?.avgResponseMin ?? 0,
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
                              () {
                                final activeIncident = incidents.valueOrNull?.firstWhere((i) => i.isActive);
                                if (activeIncident != null) {
                                  context.go('/war-room/${activeIncident.id}');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active crisis')));
                                }
                              }),
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
                      incidents.when(
                        data: (list) => list.isEmpty 
                            ? const Text('No active incidents', style: TextStyle(color: AppColors.textMuted))
                            : Column(
                                children: list.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: SlideUpReveal(
                                    delay: const Duration(milliseconds: 200),
                                    child: IncidentCard(
                                      incident: e,
                                      onTap: () =>
                                          context.go('/crisis-command/${e.id}'),
                                    ),
                                  ),
                                )).toList(),
                              ),
                        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.crisisRed)),
                        error: (e, _) => Text('Error loading incidents: $e', style: const TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(height: 22),

                      // Staff
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 380),
                        child: Text('Staff On Duty', style: AppTypography.h3),
                      ),
                      const SizedBox(height: 10),
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 420),
                        child: staff.when(
                          data: (list) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: list
                                  .map((s) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: StaffChip(
                                            name: s.name,
                                            role: s.role,
                                            status: s.onDuty ? StaffStatus.available : StaffStatus.offDuty),
                                      ))
                                  .toList(),
                            ),
                          ),
                          loading: () => const CircularProgressIndicator(color: AppColors.statusTeal),
                          error: (e, _) => const Text('Failed to load staff'),
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
      case VigilTab.myTasks:
        context.go('/staff-home');
      case VigilTab.guestHome:
        context.go('/guest-home');
      default:
        break;
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
