import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/vigil_bottom_nav.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      bottomNavigationBar: VigilBottomNav(
        current: VigilTab.profile,
        hasCrisisActive: false,
        onTabSelected: (tab) => _nav(context, tab),
      ),
      body: AuroraBackground(
        blobColors: [
          AppColors.commandBlue.withOpacity(0.08),
          AppColors.intelViolet.withOpacity(0.06),
          AppColors.statusTeal.withOpacity(0.04),
        ],
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Avatar block
              SlideUpReveal(
                delay: const Duration(milliseconds: 60),
                child: GlassCard(
                  child: Row(children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.commandBlue.withOpacity(0.25),
                          AppColors.commandBlue.withOpacity(0.06),
                        ]),
                        border: Border.all(
                            color: AppColors.commandBlue.withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          (auth.userName ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.commandBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        Text(auth.userName ?? 'User',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(auth.userEmail ?? '',
                            style: AppTypography.bodySmall),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.commandBlue
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            auth.role == UserRole.manager
                                ? 'MANAGER'
                                : 'STAFF',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.commandBlue,
                                letterSpacing: 1.5),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // Hotel
              SlideUpReveal(
                delay: const Duration(milliseconds: 100),
                child: Text('Hotel', style: AppTypography.h3),
              ),
              const SizedBox(height: 10),
              SlideUpReveal(
                delay: const Duration(milliseconds: 130),
                child: GlassCard(
                  child: _InfoRow(Icons.hotel_outlined,
                      'Property', 'Grand Hyatt Mumbai'),
                ),
              ),
              const SizedBox(height: 8),
              SlideUpReveal(
                delay: const Duration(milliseconds: 160),
                child: GlassCard(
                  child: _InfoRow(Icons.location_city_outlined,
                      'Address',
                      'Off Western Express Highway, Santacruz (E)'),
                ),
              ),
              const SizedBox(height: 8),
              SlideUpReveal(
                delay: const Duration(milliseconds: 190),
                child: GlassCard(
                  child: _InfoRow(Icons.meeting_room_outlined,
                      'Rooms', '547 guest rooms'),
                ),
              ),
              const SizedBox(height: 20),

              // Settings
              SlideUpReveal(
                delay: const Duration(milliseconds: 220),
                child: Text('Settings', style: AppTypography.h3),
              ),
              const SizedBox(height: 10),
              SlideUpReveal(
                delay: const Duration(milliseconds: 250),
                child: GlassCard(
                  child: Column(children: [
                    _ToggleRow(
                        Icons.notifications_outlined,
                        'Push Notifications',
                        true,
                        (_) {}),
                    Divider(
                        color: AppColors.borderDefault.withOpacity(0.5),
                        height: 1),
                    _ToggleRow(
                        Icons.vibration_outlined,
                        'Haptic Feedback',
                        true,
                        (_) {}),
                    Divider(
                        color: AppColors.borderDefault.withOpacity(0.5),
                        height: 1),
                    _ToggleRow(
                        Icons.nightlight_outlined,
                        'Dark Mode',
                        true,
                        (_) {}),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              SlideUpReveal(
                delay: const Duration(milliseconds: 280),
                child: GlassCard(
                  child: Column(children: [
                    _NavRow(Icons.analytics_outlined, 'Analytics',
                        () => context.go('/analytics')),
                    Divider(
                        color: AppColors.borderDefault.withOpacity(0.5),
                        height: 1),
                    _NavRow(Icons.shield_outlined, 'Privacy Policy',
                        () {}),
                    Divider(
                        color: AppColors.borderDefault.withOpacity(0.5),
                        height: 1),
                    _NavRow(
                        Icons.info_outline, 'About VIGIL v1.0.0',
                        () {}),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // Sign out
              SlideUpReveal(
                delay: const Duration(milliseconds: 320),
                child: GestureDetector(
                  onTap: () {
                    ref.read(authProvider.notifier).signOut();
                    context.go('/auth');
                  },
                  child: GlassCard(
                    borderColor: AppColors.crisisRed.withOpacity(0.35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_rounded,
                                size: 18, color: AppColors.crisisRed),
                            SizedBox(width: 10),
                            Text('SIGN OUT',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.crisisRed,
                                    letterSpacing: 1.5)),
                          ]),
                    ),
                  ),
                ),
              ),
            ]),
          ),
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
        break;
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ]),
      ]);
}

class _ToggleRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool initial;
  final ValueChanged<bool> onChange;
  const _ToggleRow(this.icon, this.label, this.initial, this.onChange);

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.initial;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(widget.icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(widget.label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textPrimary))),
          Switch(
            value: _val,
            onChanged: (v) {
              setState(() => _val = v);
              widget.onChange(v);
            },
            activeColor: AppColors.statusTeal,
            trackColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected)
                    ? AppColors.statusTeal.withOpacity(0.3)
                    : AppColors.bgElevated),
          ),
        ]),
      );
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavRow(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textPrimary))),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textMuted),
          ]),
        ),
      );
}
