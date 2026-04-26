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
    final sensorsAsync = ref.watch(floorSensorsProvider);
    final sensors = sensorsAsync.valueOrNull ?? [];

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
                for (final f in [0, 1, 2, 4])
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
                        _roomLabel('101', 0.08, 0.06, box),
                        _roomLabel('102', 0.28, 0.06, box),
                        _roomLabel('103', 0.08, 0.21, box),
                        _roomLabel('104', 0.28, 0.21, box),
                        _roomLabel('ELEVATORS', 0.08, 0.44, box, color: AppColors.commandBlue.withOpacity(0.8)),
                        _roomLabel('STAIRS A', 0.82, 0.04, box, color: AppColors.commandBlue.withOpacity(0.8)),
                        _roomLabel('STAIRS B', 0.06, 0.88, box, color: AppColors.commandBlue.withOpacity(0.8)),
                        _roomLabel('LOBBY AREA', 0.35, 0.44, box),
                        _roomLabel('KITCHEN 🔥', 0.65, 0.20, box, color: AppColors.crisisRed, size: 12),
                        _roomLabel('RESTAURANT', 0.65, 0.44, box),
                        _roomLabel('CORRIDOR A', 0.35, 0.14, box),
                        _roomLabel('CORRIDOR B', 0.35, 0.76, box),
                        _roomLabel('GYM', 0.65, 0.70, box),
                        _roomLabel('POOL', 0.65, 0.88, box, color: AppColors.statusTeal),
                        _roomLabel('RESTROOMS', 0.35, 0.60, box),

                        // Sensors
                        if (sensorsAsync.isLoading && sensors.isEmpty)
                          const Center(child: CircularProgressIndicator(color: AppColors.statusTeal))
                        else ...sensors.where((s) => s.floor == _selectedFloor).map((s) {
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
      {Color? color, double size = 10}) =>
      Positioned(
        left: rx * box.maxWidth,
        top: ry * box.maxHeight,
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size,
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
      case VigilTab.myTasks:
        context.go('/staff-home');
      case VigilTab.guestHome:
        context.go('/guest-home');
      default:
        break;
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
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final thinWall = Paint()
      ..color = AppColors.borderDefault.withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Outer boundary
    canvas.drawRect(Rect.fromLTRB(10, 10, size.width - 10, size.height - 10), wall);

    // Corridors
    canvas.drawRect(Rect.fromLTRB(size.width * 0.45, 10, size.width * 0.55, size.height - 10), thinWall); // Vertical Main Corridor
    canvas.drawRect(Rect.fromLTRB(10, size.height * 0.35, size.width - 10, size.height * 0.55), thinWall); // Horizontal Main Corridor

    // Left Wing Rooms (101, 102, 103, 104)
    canvas.drawLine(Offset(10, size.height * 0.175), Offset(size.width * 0.45, size.height * 0.175), thinWall);
    canvas.drawLine(Offset(size.width * 0.225, 10), Offset(size.width * 0.225, size.height * 0.35), thinWall);

    // Elevators
    final elevRect = Rect.fromLTRB(10, size.height * 0.40, size.width * 0.25, size.height * 0.50);
    canvas.drawRect(elevRect, wall);
    canvas.drawLine(elevRect.topLeft, elevRect.bottomRight, thinWall);
    canvas.drawLine(elevRect.topRight, elevRect.bottomLeft, thinWall);

    // Stairs A
    final stairsARect = Rect.fromLTRB(size.width * 0.80, 10, size.width - 10, size.height * 0.15);
    canvas.drawRect(stairsARect, wall);
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(stairsARect.left, stairsARect.top + (stairsARect.height / 6) * i),
        Offset(stairsARect.right, stairsARect.top + (stairsARect.height / 6) * i),
        thinWall,
      );
    }

    // Stairs B
    final stairsBRect = Rect.fromLTRB(10, size.height * 0.85, size.width * 0.25, size.height - 10);
    canvas.drawRect(stairsBRect, wall);
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(stairsBRect.left, stairsBRect.top + (stairsBRect.height / 6) * i),
        Offset(stairsBRect.right, stairsBRect.top + (stairsBRect.height / 6) * i),
        thinWall,
      );
    }

    // Kitchen
    final kitchenRect = Rect.fromLTRB(size.width * 0.55, 10, size.width * 0.80, size.height * 0.35);
    canvas.drawRect(kitchenRect, wall);

    // Kitchen hatching (alert zone)
    final hatch = Paint()
      ..color = AppColors.crisisRed.withOpacity(0.06)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 20; i++) {
      final x = kitchenRect.left + i * 10.0;
      if (x < kitchenRect.right) {
        canvas.drawLine(Offset(x, kitchenRect.top), Offset(x + 30, kitchenRect.bottom), hatch);
      }
    }

    // Restaurant
    canvas.drawRect(Rect.fromLTRB(size.width * 0.55, size.height * 0.35, size.width - 10, size.height * 0.55), thinWall);

    // Restrooms
    canvas.drawRect(Rect.fromLTRB(size.width * 0.25, size.height * 0.55, size.width * 0.45, size.height * 0.70), thinWall);
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.55), Offset(size.width * 0.35, size.height * 0.70), thinWall);

    // Gym
    canvas.drawRect(Rect.fromLTRB(size.width * 0.55, size.height * 0.55, size.width - 10, size.height * 0.80), thinWall);

    // Pool
    final poolRect = Rect.fromLTRB(size.width * 0.55, size.height * 0.80, size.width - 10, size.height - 10);
    canvas.drawRect(poolRect, thinWall);
    
    // Pool water waves
    final water = Paint()
      ..color = AppColors.statusTeal.withOpacity(0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
    canvas.drawRect(poolRect.deflate(5), water);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
