import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/animations/severity_pulse_badge.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/firebase_service.dart';
import 'dashboard_provider.dart';

class IncidentDetailScreen extends ConsumerWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incident = ref.watch(incidentByIdProvider(incidentId));

    if (incident == null) {
      return const Scaffold(
        body: Center(child: Text('Loading or not found...', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          incident.crisisSeverity.color.withOpacity(0.1),
          AppColors.intelViolet.withOpacity(0.05),
          AppColors.statusTeal.withOpacity(0.05),
        ],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderDefault),
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('Incident Details',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 100),
                        child: GlassCard(
                          borderColor: incident.crisisSeverity.color.withOpacity(0.5),
                          glowColor: incident.crisisSeverity.color.withOpacity(0.2),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SeverityPulseBadge(severity: incident.crisisSeverity),
                                  const Spacer(),
                                  Text(incident.timeAgo, style: AppTypography.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(incident.title, style: AppTypography.h1),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(incident.location, style: AppTypography.body)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 150),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NOTES', style: AppTypography.label),
                              const SizedBox(height: 10),
                              Text(incident.notes.isEmpty ? 'No notes provided.' : incident.notes,
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 200),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ASSIGNED STAFF (${incident.assignedCount})', style: AppTypography.label),
                              const SizedBox(height: 10),
                              if (incident.assignedTo.isEmpty)
                                const Text('No staff assigned.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMuted))
                              else
                                ...incident.assignedTo.map((staff) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(color: AppColors.statusTeal, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(staff, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SlideUpReveal(
                        delay: const Duration(milliseconds: 250),
                        child: incident.status == 'resolved' ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.safeGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.safeGreen.withOpacity(0.5)),
                            ),
                            child: const Center(
                              child: Text('RESOLVED',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.safeGreen, letterSpacing: 2)),
                            ),
                          ) : GestureDetector(
                          onTap: () async {
                            await ref.read(firebaseProvider).resolveIncident(incident.id);
                            ref.invalidate(hotelStatsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Incident resolved successfully', style: TextStyle(color: Colors.white)),
                                  backgroundColor: AppColors.safeGreen,
                                  behavior: SnackBarBehavior.floating,
                                )
                              );
                              context.pop();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.safeGreen, Color(0xFF1A8C4E)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: AppColors.safeGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: const Center(
                              child: Text('ALL CLEAR',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
}
