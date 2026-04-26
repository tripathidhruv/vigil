import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/manager_dashboard_screen.dart';
import '../../features/crisis_activation/crisis_activation_screen.dart';
import '../../features/crisis_command/crisis_command_screen.dart';
import '../../features/staff_home/staff_home_screen.dart';
import '../../features/guest/guest_home_screen.dart';
import '../../features/war_room/war_room_screen.dart';
import '../../features/floor_map/floor_map_screen.dart';
import '../../features/guest_alert/guest_alert_screen.dart';
import '../../features/drill/drill_mode_screen.dart';
import '../../features/compliance/compliance_report_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/dashboard/incident_detail_screen.dart';
import '../../core/demo/demo_data.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      final role = authState.role;
      final path = state.uri.path;

      // Allow unauthenticated users on splash, onboarding, and auth screens
      if (!isLoggedIn) {
        if (path == '/splash' || path == '/onboarding' || path == '/auth') return null;
        return '/auth';
      }

      // Role-based guarding for manager-only routes
      final managerRoutes = ['/dashboard', '/crisis-command', '/crisis-activation', '/compliance', '/analytics'];
      if (managerRoutes.any((r) => path.startsWith(r))) {
        if (role != UserRole.manager) {
          return role == UserRole.guest ? '/guest-home' : '/staff-home';
        }
      }

      // Guest guarding (guests shouldn't access staff routes)
      final operationalRoutes = ['/staff-home', '/drill', '/incident'];
      if (operationalRoutes.any((r) => path.startsWith(r))) {
        if (role == UserRole.guest) return '/guest-home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash',           builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding',       builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth',             builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/dashboard',        builder: (_, __) => const ManagerDashboardScreen()),
      GoRoute(path: '/crisis-activation',builder: (_, __) => const CrisisActivationScreen()),
      GoRoute(
        path: '/crisis-command/:id',
        builder: (_, state) => CrisisCommandScreen(incidentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/staff-home',       builder: (_, __) => const StaffHomeScreen()),
      GoRoute(path: '/guest-home',       builder: (_, __) => const GuestHomeScreen()),
      GoRoute(
        path: '/war-room',
        builder: (_, state) {
          final id = state.uri.queryParameters['id'] ?? demoIncidents[0].id;
          return WarRoomScreen(incidentId: id);
        },
      ),
      GoRoute(
        path: '/war-room/:id',
        builder: (_, state) => WarRoomScreen(incidentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/incident/:id',
        builder: (_, state) => IncidentDetailScreen(incidentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/floor-map',        builder: (_, __) => const FloorMapScreen()),
      GoRoute(
        path: '/guest-alert',
        builder: (_, state) {
          final id = state.uri.queryParameters['id'];
          return GuestAlertScreen(incidentId: id);
        },
      ),
      GoRoute(path: '/drill',            builder: (_, __) => const DrillModeScreen()),
      GoRoute(
        path: '/compliance',
        builder: (_, state) {
          final id = state.uri.queryParameters['id'];
          return ComplianceReportScreen(incidentId: id);
        },
      ),
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
});
