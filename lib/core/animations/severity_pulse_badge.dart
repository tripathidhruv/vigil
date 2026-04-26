import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CrisisSeverity { critical, high, moderate, low }

extension CrisisSeverityX on CrisisSeverity {
  Color get color {
    switch (this) {
      case CrisisSeverity.critical:
        return AppColors.crisisRed;
      case CrisisSeverity.high:
        return AppColors.alertOrange;
      case CrisisSeverity.moderate:
        return AppColors.warningAmber;
      case CrisisSeverity.low:
        return AppColors.commandBlue;
    }
  }

  String get label {
    switch (this) {
      case CrisisSeverity.critical:
        return 'CRITICAL';
      case CrisisSeverity.high:
        return 'HIGH';
      case CrisisSeverity.moderate:
        return 'MODERATE';
      case CrisisSeverity.low:
        return 'LOW';
    }
  }
}

/// A severity badge with pulsing ring and colored pill background.
class SeverityPulseBadge extends StatefulWidget {
  final CrisisSeverity severity;
  final bool compact;

  const SeverityPulseBadge({
    super.key,
    required this.severity,
    this.compact = false,
  });

  @override
  State<SeverityPulseBadge> createState() => _SeverityPulseBadgeState();
}

class _SeverityPulseBadgeState extends State<SeverityPulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.severity.color;
    final label = widget.severity.label;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        final ringOpacity = reduceMotion
            ? 0.3
            : 0.15 + (_pulseAnim.value * 0.3);
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 10,
            vertical: widget.compact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withOpacity(ringOpacity),
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: widget.compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
