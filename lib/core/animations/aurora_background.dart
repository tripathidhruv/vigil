import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated aurora background with 3 slowly drifting radial gradient blobs.
/// Place this as the bottom-most layer behind GlassCard widgets.
class AuroraBackground extends StatefulWidget {
  final Widget? child;

  /// Override blob colors. Defaults to the VIGIL dark command center palette.
  final List<Color>? blobColors;

  const AuroraBackground({super.key, this.child, this.blobColors});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  // Each blob has x/y phase offsets for independent sinusoidal movement
  final List<_BlobConfig> _blobs = [
    _BlobConfig(xPhase: 0.0, yPhase: 0.5, xAmp: 0.35, yAmp: 0.3, radius: 0.55, duration: 14),
    _BlobConfig(xPhase: 2.0, yPhase: 1.2, xAmp: 0.30, yAmp: 0.35, radius: 0.50, duration: 17),
    _BlobConfig(xPhase: 4.0, yPhase: 2.5, xAmp: 0.25, yAmp: 0.40, radius: 0.45, duration: 12),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: _blobs[i].duration),
      )..repeat();
    });
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: 2 * pi).animate(c))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<Color> get _blobColors =>
      widget.blobColors ??
      [
        AppColors.crisisRed.withOpacity(0.08),
        AppColors.intelViolet.withOpacity(0.06),
        AppColors.statusTeal.withOpacity(0.06),
      ];

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Void black base
        Container(color: AppColors.bgVoid),

        // Aurora blobs
        if (!reduceMotion)
          AnimatedBuilder(
            animation: Listenable.merge(_animations),
            builder: (context, _) {
              return CustomPaint(
                painter: _AuroraPainter(
                  animations: _animations,
                  blobs: _blobs,
                  colors: _blobColors,
                ),
              );
            },
          )
        else
          // Static blobs when animations disabled
          CustomPaint(
            painter: _AuroraPainter(
              animations: _animations,
              blobs: _blobs,
              colors: _blobColors,
              staticMode: true,
            ),
          ),

        // Child content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _BlobConfig {
  final double xPhase, yPhase, xAmp, yAmp, radius;
  final int duration;
  const _BlobConfig({
    required this.xPhase,
    required this.yPhase,
    required this.xAmp,
    required this.yAmp,
    required this.radius,
    required this.duration,
  });
}

class _AuroraPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final List<_BlobConfig> blobs;
  final List<Color> colors;
  final bool staticMode;

  _AuroraPainter({
    required this.animations,
    required this.blobs,
    required this.colors,
    this.staticMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      final t = staticMode ? blob.xPhase : animations[i].value;

      final cx = size.width * (0.5 + blob.xAmp * sin(t + blob.xPhase));
      final cy = size.height * (0.5 + blob.yAmp * cos(t + blob.yPhase));
      final r = size.shortestSide * blob.radius;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[i], Colors.transparent],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => !staticMode;
}
