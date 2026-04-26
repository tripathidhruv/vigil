import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'staff_provider.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffProvider);
    final done = state.tasks.where((t) => t.completed).length;

    return Scaffold(
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
                  Text(state.name,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('${state.role} · ${state.shiftTime}',
                      style: AppTypography.bodySmall),
                ]),
                const Spacer(),
                // Panic button
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    await ref.read(staffProvider.notifier).sendPanic();
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
                      Text('Today\'s Tasks',
                          style: AppTypography.h3),
                      const Spacer(),
                      Text('$done / ${state.tasks.length} done',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.statusTeal)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: state.tasks.isEmpty
                            ? 0
                            : done / state.tasks.length,
                        minHeight: 4,
                        backgroundColor: AppColors.borderDefault,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.statusTeal),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active crisis banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SlideUpReveal(
                delay: const Duration(milliseconds: 120),
                child: GestureDetector(
                  onTap: () => context.go('/crisis-command'),
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
                            const Text('ACTIVE INCIDENT',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.crisisRed,
                                    letterSpacing: 1.5)),
                            const SizedBox(height: 2),
                            Text('Kitchen fire — Floor 2 · Kitchen walkthrough assigned',
                                style: AppTypography.bodySmall),
                          ])),
                      const Icon(Icons.chevron_right,
                          color: AppColors.crisisRed),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Task list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                itemCount: state.tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final task = state.tasks[i];
                  return SlideUpReveal(
                    delay: Duration(milliseconds: 160 + i * 55),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(staffProvider.notifier)
                          .toggleTask(task.id),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        borderColor: task.completed
                            ? AppColors.safeGreen.withOpacity(0.3)
                            : AppColors.borderDefault,
                        child: Row(children: [
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: task.completed
                                  ? AppColors.statusTeal
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.completed
                                    ? AppColors.statusTeal
                                    : AppColors.borderDefault,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: task.completed
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Text(task.title,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: task.completed
                                        ? AppColors.textMuted
                                        : AppColors.textPrimary,
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  )),
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(task.location,
                                    style:
                                        AppTypography.bodySmall),
                              ]),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom quick actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(
                    top: BorderSide(color: AppColors.borderDefault)),
              ),
              child: Row(children: [
                _FooterBtn('War Room', Icons.crisis_alert,
                    AppColors.warningAmber, () => context.go('/war-room')),
                const SizedBox(width: 10),
                _FooterBtn('Floor Map', Icons.map_outlined,
                    AppColors.statusTeal, () => context.go('/floor-map')),
                const SizedBox(width: 10),
                _FooterBtn('Profile', Icons.person_outline,
                    AppColors.commandBlue, () => context.go('/profile')),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FooterBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FooterBtn(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ]),
          ),
        ),
      );
}
