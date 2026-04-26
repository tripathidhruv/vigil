// dart:math not needed — painter uses direct pixel offsets
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import 'floor_map_provider.dart';

class FloorMapScreen extends ConsumerStatefulWidget {
  const FloorMapScreen({super.key});
  @override
  ConsumerState<FloorMapScreen> createState() => _FloorMapScreenState();
}

class _FloorMapScreenState extends ConsumerState<FloorMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  int _selectedFloor = 2;
  SensorData? _selected;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(SensorStatus s) => switch (s) {
        SensorStatus.normal => AppColors.safeGreen,
        SensorStatus.warning => AppColors.warningAmber,
        SensorStatus.alert => AppColors.crisisRed,
        SensorStatus.offline => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final sensors = ref.watch(floorSensorsProvider);

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.map,
        hasCrisisActive: true,
        onTabSelected: (tab) => _nav(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.statusTeal.withOpacity(0.08),
          AppColors.commandBlue.withOpacity(0.06),
          AppColors.intelViolet.withOpacity(0.05),
        ],
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            // Header
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
                const Text('Floor Map',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                // Alert count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.crisisRedDim,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    '${sensors.where((s) => s.status == SensorStatus.alert).length} ALERTS',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crisisRed,
                        letterSpacing: 1.5),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // Floor selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                for (final f in [1, 2, 3, 4, 5])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFloor = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedFloor == f
                              ? AppColors.statusTeal.withOpacity(0.15)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _selectedFloor == f
                                  ? AppColors.statusTeal
                                  : AppColors.borderDefault,
                              width: 1.5),
                        ),
                        child: Row(children: [
                          Text('Floor $_selectedFloor',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedFloor == f
                                      ? AppColors.statusTeal
                                      : AppColors.textSecondary)),
                          if (f == 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                    color: AppColors.crisisRed,
                                    shape: BoxShape.circle),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 14),

            // Map canvas
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LayoutBuilder(builder: (ctx, box) {
                      return Stack(children: [
                        // Grid background
                        CustomPaint(
                          size: Size(box.maxWidth, box.maxHeight),
                          painter: _FloorGridPainter(),
                        ),
                        // Room labels
                        _roomLabel('Room 101', 0.05, 0.10, box),
                        _roomLabel('Room 102', 0.28, 0.10, box),
                        _roomLabel('Lobby', 0.05, 0.42, box),
                        _roomLabel('Corridor A', 0.35, 0.42, box),
                        _roomLabel('KITCHEN 🔥', 0.60, 0.10, box,
                            color: AppColors.crisisRed),
                        _roomLabel('Corridor B', 0.42, 0.65, box),
                        _roomLabel('Fire Exit', 0.78, 0.60, box),

                        // Sensors
                        ...sensors.map((s) {
                          final x = s.rx * box.maxWidth;
                          final y = s.ry * box.maxHeight;
                          final c = _statusColor(s.status);
                          return Positioned(
                            left: x - 14,
                            top: y - 14,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selected = s),
                              child: AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (_, __) {
                                  final pulse = s.status ==
                                          SensorStatus.alert
                                      ? (1.0 +
                                          _pulseCtrl.value * 0.4)
                                      : 1.0;
                                  return Transform.scale(
                                    scale: pulse,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: c.withOpacity(0.20),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: c, width: 1.5),
                                      ),
                                      child: Icon(
                                        s.status == SensorStatus.offline
                                            ? Icons.wifi_off
                                            : Icons.sensors,
                                        size: 14,
                                        color: c,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                for (final e in [
                  (AppColors.safeGreen, 'Normal'),
                  (AppColors.warningAmber, 'Warning'),
                  (AppColors.crisisRed, 'Alert'),
                  (AppColors.textMuted, 'Offline'),
                ])
                  Expanded(
                    child: Row(children: [
                      Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                              color: e.$1, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(e.$2,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textMuted)),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 10),

            // Selected sensor detail
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: GlassCard(
                  borderColor: _statusColor(_selected!.status)
                      .withOpacity(0.4),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                          color: _statusColor(_selected!.status)
                              .withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.sensors,
                          size: 18,
                          color: _statusColor(_selected!.status)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        Text(
                            '${_selected!.label} · ${_selected!.room}',
                            style: AppTypography.h3
                                .copyWith(fontSize: 14)),
                        Text(
                            _selected!.status.name
                                .toUpperCase(),
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _statusColor(
                                    _selected!.status),
                                letterSpacing: 1.5)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selected = null),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.textMuted),
                    ),
                  ]),
                ),
              ),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    );
  }

  Widget _roomLabel(
      String label, double rx, double ry, BoxConstraints box,
      {Color? color}) =>
      Positioned(
        left: rx * box.maxWidth,
        top: ry * box.maxHeight,
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.textMuted.withOpacity(0.55))),
      );

  void _nav(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.dashboard:
        context.go('/dashboard');
      case VigilTab.warRoom:
        context.go('/war-room');
      case VigilTab.map:
        break;
      case VigilTab.notifications:
        context.go('/notifications');
      case VigilTab.profile:
        context.go('/profile');
    }
  }
}

// ── Floor grid painter ────────────────────────────────────────────────────────

class _FloorGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.bgElevated;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final wall = Paint()
      ..color = AppColors.borderDefault.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Outer boundary
    canvas.drawRect(
        Rect.fromLTRB(10, 10, size.width - 10, size.height - 10), wall);

    // Room dividers
    final mid = Paint()
      ..color = AppColors.borderDefault.withOpacity(0.35)
      ..strokeWidth = 1;
    // Vertical
    canvas.drawLine(Offset(size.width * 0.5, 10),
        Offset(size.width * 0.5, size.height * 0.35), mid);
    // Horizontal mid
    canvas.drawLine(Offset(10, size.height * 0.35),
        Offset(size.width - 10, size.height * 0.35), mid);
    // Horizontal bottom
    canvas.drawLine(Offset(10, size.height * 0.60),
        Offset(size.width - 10, size.height * 0.60), mid);

    // Kitchen hatching (alert zone)
    final hatch = Paint()
      ..color = AppColors.crisisRed.withOpacity(0.04)
      ..strokeWidth = 1;
    for (int i = 0; i < 12; i++) {
      final x = size.width * 0.5 + i * 14.0;
      canvas.drawLine(
          Offset(x, 10), Offset(x + 60, size.height * 0.35), hatch);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
