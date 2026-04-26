import 'package:flutter/material.dart';
import '../animations/severity_pulse_badge.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';
import 'package:go_router/go_router.dart';

import '../../models/incident_model.dart';

/// A bento-grid incident card for the dashboard and war room list.
class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback? onTap;
  final bool compact;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = incident.isActive
        ? AppColors.glassRedBorder
        : AppColors.glassBorder;
    final glowColor = incident.isActive ? AppColors.crisisRed : null;

    return GlassCard(
      borderColor: borderColor,
      glowColor: glowColor,
      padding: EdgeInsets.all(compact ? 12 : 16),
      onTap: onTap ?? () => context.push('/incident/${incident.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SeverityPulseBadge(
                severity: incident.crisisSeverity,
                compact: compact,
              ),
              const Spacer(),
              Text(incident.timeAgo, style: AppTypography.bodySmall),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            incident.title,
            style: compact ? AppTypography.h3 : AppTypography.h2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  incident.location,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!compact && incident.assignedCount > 0) ...[
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: AppColors.borderDefault,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${incident.assignedCount} staff assigned',
                  style: AppTypography.bodySmall,
                ),
                const Spacer(),
                if (incident.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.crisisRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.crisisRed,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
