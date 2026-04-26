import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsProvider);

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.dashboard,
        hasCrisisActive: false,
        onTabSelected: (tab) => _nav(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.commandBlue.withOpacity(0.09),
          AppColors.statusTeal.withOpacity(0.06),
          AppColors.intelViolet.withOpacity(0.05),
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
                const Text('Analytics',
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
                      color: AppColors.commandBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('LAST 7 WEEKS',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.commandBlue,
                          letterSpacing: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: data.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
                data: (a) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                    // KPI row
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 60),
                      child: Row(children: [
                        _Kpi('TOTAL', '${a.totalIncidents}',
                            AppColors.commandBlue),
                        const SizedBox(width: 10),
                        _Kpi('AVG RESP.',
                            '${a.avgResponseMin} min',
                            AppColors.statusTeal),
                        const SizedBox(width: 10),
                        _Kpi('RESOLVED',
                            '${a.resolutionRate}%',
                            AppColors.safeGreen),
                      ]),
                    ),
                    const SizedBox(height: 22),

                    // Bar chart — incidents by type
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 110),
                      child: Text('Incidents by Type',
                          style: AppTypography.h3),
                    ),
                    const SizedBox(height: 12),
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 140),
                      child: GlassCard(
                        child: Column(children: [
                          for (final s in a.incidentsByType)
                            _BarRow(s),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Line chart — response time
                    SlideUpReveal(
                      delay:
                          const Duration(milliseconds: 190),
                      child: Text('Avg Response Time (min)',
                          style: AppTypography.h3),
                    ),
                    const SizedBox(height: 12),
                    SlideUpReveal(
                      delay:
                          const Duration(milliseconds: 220),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 120,
                          child: CustomPaint(
                              painter: _LinePainter(
                                  a.responseTimeTrend)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // AI Insights
                    SlideUpReveal(
                      delay:
                          const Duration(milliseconds: 260),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome,
                            size: 16,
                            color: AppColors.intelViolet),
                        const SizedBox(width: 8),
                        Text('Gemini Insights',
                            style: AppTypography.h3),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    ...a.insights.asMap().entries.map((e) =>
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10),
                          child: SlideUpReveal(
                            delay: Duration(
                                milliseconds:
                                    290 + e.key * 60),
                            child: GlassCard(
                              borderColor: AppColors.intelViolet
                                  .withOpacity(0.25),
                              child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.intelViolet
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                        '${e.key + 1}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: AppColors
                                              .intelViolet,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            color: AppColors
                                                .textPrimary,
                                            height: 1.55))),
                              ]),
                            ),
                          ),
                        )),
                  ]),
                ),
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

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Kpi(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 12),
          borderColor: color.withOpacity(0.25),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ]),
        ),
      );
}

class _BarRow extends StatelessWidget {
  final BarStat stat;
  const _BarRow(this.stat);

  Color get _color => switch (stat.colorKey) {
        'red' => AppColors.crisisRed,
        'amber' => AppColors.warningAmber,
        'blue' => AppColors.commandBlue,
        'teal' => AppColors.statusTeal,
        _ => AppColors.alertOrange,
      };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(
              width: 66,
              child: Text(stat.label,
                  style: AppTypography.bodySmall)),
          const SizedBox(width: 10),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: stat.value / 20),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: AppColors.bgElevated,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
              width: 28,
              child: Text('${stat.value.toInt()}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _color))),
        ]),
      );
}

class _LinePainter extends CustomPainter {
  final List<LineStat> stats;
  const _LinePainter(this.stats);

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;
    final maxY =
        stats.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY =
        stats.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final rangeY = (maxY - minY).clamp(1.0, double.infinity);

    double px(LineStat s) =>
        s.x / (stats.length - 1) * size.width;
    double py(LineStat s) =>
        size.height - ((s.y - minY) / rangeY * size.height * 0.8 + size.height * 0.1);

    final linePaint = Paint()
      ..color = AppColors.statusTeal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.statusTeal.withOpacity(0.25),
          AppColors.statusTeal.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    path.moveTo(px(stats.first), py(stats.first));
    fillPath.moveTo(px(stats.first), size.height);
    fillPath.lineTo(px(stats.first), py(stats.first));

    for (int i = 1; i < stats.length; i++) {
      final prev = stats[i - 1];
      final curr = stats[i];
      final cp1x = px(prev) + (px(curr) - px(prev)) / 2;
      path.cubicTo(cp1x, py(prev), cp1x, py(curr), px(curr), py(curr));
      fillPath.cubicTo(
          cp1x, py(prev), cp1x, py(curr), px(curr), py(curr));
    }

    fillPath.lineTo(px(stats.last), size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Dots
    final dotPaint = Paint()
      ..color = AppColors.statusTeal
      ..style = PaintingStyle.fill;
    for (final s in stats) {
      canvas.drawCircle(Offset(px(s), py(s)), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
