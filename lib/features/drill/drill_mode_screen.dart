import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/animations/severity_pulse_badge.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'drill_provider.dart';

class DrillModeScreen extends ConsumerWidget {
  const DrillModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(drillProvider);

    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          AppColors.intelViolet.withOpacity(0.10),
          AppColors.commandBlue.withOpacity(0.07),
          AppColors.statusTeal.withOpacity(0.05),
        ],
        child: SafeArea(
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
                const Text('Drill Mode',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.intelViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('SIMULATION',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.intelViolet,
                          letterSpacing: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: _buildBody(context, ref, state),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, DrillState state) {
    switch (state.phase) {
      case DrillPhase.selecting:
        return _ScenarioSelector(ref: ref);
      case DrillPhase.active:
        return _ActiveDrill(ref: ref, state: state);
      case DrillPhase.completed:
        return _DrillResult(context: context, ref: ref, state: state);
    }
  }
}

// ── Scenario Selector ─────────────────────────────────────────────────────────

class _ScenarioSelector extends StatelessWidget {
  final WidgetRef ref;
  const _ScenarioSelector({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SlideUpReveal(
        delay: const Duration(milliseconds: 60),
        child: GlassCard(
          borderColor: AppColors.intelViolet.withOpacity(0.3),
          child: Row(children: [
            const Icon(Icons.info_outline,
                size: 16, color: AppColors.intelViolet),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Drills are SIMULATED. No real alerts or notifications are sent.',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.intelViolet),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 20),
      SlideUpReveal(
        delay: const Duration(milliseconds: 100),
        child: Text('Choose a Scenario', style: AppTypography.h2),
      ),
      const SizedBox(height: 12),
      ...kDrillScenarios.asMap().entries.map((e) {
        final s = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SlideUpReveal(
            delay: Duration(milliseconds: 140 + e.key * 60),
            child: GestureDetector(
              onTap: () =>
                  ref.read(drillProvider.notifier).startDrill(s),
              child: GlassCard(
                borderColor: AppColors.borderDefault,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SeverityPulseBadge(severity: s.severity),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      Text(s.title,
                          style: AppTypography.h3
                              .copyWith(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(s.description,
                          style: AppTypography.bodySmall
                              .copyWith(height: 1.5)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.timer_outlined,
                            size: 13,
                            color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                            'Target: ${s.durationMin} min',
                            style: AppTypography.bodySmall),
                        const SizedBox(width: 12),
                        const Icon(Icons.category_outlined,
                            size: 13,
                            color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(s.type,
                            style: AppTypography.bodySmall),
                      ]),
                    ]),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textMuted),
                ]),
              ),
            ),
          ),
        );
      }),
    ]);
  }
}

// ── Active Drill ──────────────────────────────────────────────────────────────

class _ActiveDrill extends StatelessWidget {
  final WidgetRef ref;
  final DrillState state;
  const _ActiveDrill({required this.ref, required this.state});

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final target = (state.scenario?.durationMin ?? 10) * 60;
    final progress = (state.timerSeconds / target).clamp(0.0, 1.0);

    return Column(children: [
      const SizedBox(height: 20),
      SeverityPulseBadge(severity: state.scenario!.severity),
      const SizedBox(height: 20),
      Text(state.scenario!.title,
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(fontSize: 22)),
      const SizedBox(height: 6),
      Text(state.scenario!.type,
          style: AppTypography.bodySmall),
      const SizedBox(height: 40),

      // Timer ring
      SizedBox(
        width: 180, height: 180,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 180, height: 180,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppColors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.8
                    ? AppColors.statusTeal
                    : AppColors.warningAmber,
              ),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_fmt(state.timerSeconds),
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1)),
            Text('/ ${_fmt(target)} target',
                style: AppTypography.bodySmall),
          ]),
        ]),
      ),
      const SizedBox(height: 40),

      GestureDetector(
        onTap: () => ref.read(drillProvider.notifier).completeDrill(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.safeGreen, const Color(0xFF1A8C4E)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.safeGreen.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('COMPLETE DRILL',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2)),
          ),
        ),
      ),
    ]);
  }
}

// ── Drill Result ──────────────────────────────────────────────────────────────

class _DrillResult extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;
  final DrillState state;
  const _DrillResult(
      {required this.context, required this.ref, required this.state});

  Color get _scoreColor => state.score >= 90
      ? AppColors.safeGreen
      : state.score >= 75
          ? AppColors.warningAmber
          : AppColors.crisisRed;

  @override
  Widget build(BuildContext ctx) {
    return Column(children: [
      const SizedBox(height: 20),
      Text('Drill Complete!', style: AppTypography.h1),
      const SizedBox(height: 24),
      // Score ring
      SizedBox(
        width: 140, height: 140,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 140, height: 140,
            child: CircularProgressIndicator(
              value: state.score / 100,
              strokeWidth: 10,
              backgroundColor: AppColors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${state.score}',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: _scoreColor)),
            Text('/ 100', style: AppTypography.bodySmall),
          ]),
        ]),
      ),
      const SizedBox(height: 28),
      GlassCard(
        borderColor: AppColors.intelViolet.withOpacity(0.3),
        glowColor: AppColors.intelViolet,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            const Icon(Icons.auto_awesome,
                size: 16, color: AppColors.intelViolet),
            const SizedBox(width: 8),
            Text('GEMINI FEEDBACK',
                style: AppTypography.label
                    .copyWith(color: AppColors.intelViolet)),
          ]),
          const SizedBox(height: 12),
          Text(state.feedback,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6)),
        ]),
      ),
      const SizedBox(height: 28),
      GestureDetector(
        onTap: () => ref.read(drillProvider.notifier).reset(),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderColor: AppColors.intelViolet.withOpacity(0.4),
          child: const Center(
            child: Text('RUN ANOTHER DRILL',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.intelViolet,
                    letterSpacing: 1.5)),
          ),
        ),
      ),
    ]);
  }
}
