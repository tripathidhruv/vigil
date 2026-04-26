import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/manager_dashboard_screen.dart';
import '../../features/crisis_activation/crisis_activation_screen.dart';
import '../../features/crisis_command/crisis_command_screen.dart';
import '../../features/staff_home/staff_home_screen.dart';
import '../../features/war_room/war_room_screen.dart';
import '../../features/floor_map/floor_map_screen.dart';
import '../../features/guest_alert/guest_alert_screen.dart';
import '../../features/drill/drill_mode_screen.dart';
import '../../features/compliance/compliance_report_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',           builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',       builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/auth',             builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/dashboard',        builder: (_, __) => const ManagerDashboardScreen()),
    GoRoute(path: '/crisis-activation',builder: (_, __) => const CrisisActivationScreen()),
    GoRoute(path: '/crisis-command',   builder: (_, __) => const CrisisCommandScreen()),
    GoRoute(path: '/staff-home',       builder: (_, __) => const StaffHomeScreen()),
    GoRoute(path: '/war-room',         builder: (_, __) => const WarRoomScreen()),
    GoRoute(path: '/floor-map',        builder: (_, __) => const FloorMapScreen()),
    GoRoute(path: '/guest-alert',      builder: (_, __) => const GuestAlertScreen()),
    GoRoute(path: '/drill',            builder: (_, __) => const DrillModeScreen()),
    GoRoute(path: '/compliance',       builder: (_, __) => const ComplianceReportScreen()),
    GoRoute(path: '/analytics',        builder: (_, __) => const AnalyticsScreen()),
    GoRoute(path: '/notifications',    builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/profile',          builder: (_, __) => const ProfileScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri.path}',
        style: const TextStyle(color: Colors.white70),
      ),
    ),
  ),
);
