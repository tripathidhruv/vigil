import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../animations/pulsing_dot.dart';

enum StaffStatus { available, onScene, offDuty }

extension StaffStatusX on StaffStatus {
  Color get color {
    switch (this) {
      case StaffStatus.available:
        return AppColors.safeGreen;
      case StaffStatus.onScene:
        return AppColors.crisisRed;
      case StaffStatus.offDuty:
        return AppColors.textMuted;
    }
  }

  String get label {
    switch (this) {
      case StaffStatus.available:
        return 'Available';
      case StaffStatus.onScene:
        return 'On Scene';
      case StaffStatus.offDuty:
        return 'Off Duty';
    }
  }
}

/// Staff member chip showing avatar initial, name, role, and live status dot.
class StaffChip extends StatelessWidget {
  final String name;
  final String role;
  final StaffStatus status;
  final VoidCallback? onTap;
  final bool selected;

  const StaffChip({
    super.key,
    required this.name,
    required this.role,
    required this.status,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final statusColor = status.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.statusTeal.withOpacity(0.12)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.statusTeal : AppColors.borderDefault,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgElevated,
                border: Border.all(color: AppColors.borderDefault),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTypography.h3),
                const SizedBox(height: 2),
                Text(role, style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulsingDot(color: statusColor, size: 7),
                const SizedBox(height: 2),
                Text(
                  status.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
