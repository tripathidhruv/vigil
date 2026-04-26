import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import '../auth/auth_provider.dart';

class GuestHomeScreen extends ConsumerWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.guestHome,
        hasCrisisActive: false,
        onTabSelected: (tab) => _navTo(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.intelViolet.withOpacity(0.08),
          AppColors.statusTeal.withOpacity(0.06),
          AppColors.commandBlue.withOpacity(0.04),
        ],
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome to Grand Hotel',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('${user?.name ?? 'Guest'} · Room 412',
                      style: AppTypography.bodySmall),
                ]),
              ]),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 100),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.commandBlue,
                              content: Text('Your request has been sent to hotel staff.',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          borderColor: AppColors.commandBlue.withOpacity(0.3),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.commandBlue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.room_service_outlined, color: AppColors.commandBlue),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Request Assistance',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('Towels, room service, or general help.',
                                        style: AppTypography.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 150),
                      child: GestureDetector(
                        onTap: () => context.push('/floor-map'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          borderColor: AppColors.statusTeal.withOpacity(0.3),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.statusTeal.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.map_outlined, color: AppColors.statusTeal),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('View Hotel Map',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('Find exits, facilities, and muster points.',
                                        style: AppTypography.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.bgCard,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.borderDefault)),
                              title: const Text('SOS Sent', style: TextStyle(color: AppColors.crisisRed, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                              content: const Text('SOS Alert has been sent to hotel security. Please remain calm and wait for instructions.', style: TextStyle(color: AppColors.textPrimary)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK', style: TextStyle(color: AppColors.commandBlue)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          borderColor: AppColors.crisisRed.withOpacity(0.5),
                          glowColor: AppColors.crisisRed,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.crisisRed, size: 28),
                              const SizedBox(width: 12),
                              const Text('EMERGENCY SOS',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.crisisRed,
                                      letterSpacing: 2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _navTo(BuildContext context, VigilTab tab) {
    switch (tab) {
      case VigilTab.guestHome:
        break;
      case VigilTab.notifications:
        context.go('/notifications');
      case VigilTab.profile:
        context.go('/profile');
      case VigilTab.myTasks:
        context.go('/staff-home');
      default:
        break;
    }
  }
}
