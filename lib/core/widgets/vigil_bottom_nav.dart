import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/notifications/notifications_provider.dart';

import '../../features/auth/auth_provider.dart';

enum VigilTab { dashboard, warRoom, map, notifications, profile, myTasks, guestHome }

/// Custom bottom navigation bar for VIGIL screens.
class VigilBottomNav extends ConsumerWidget {
  final VigilTab current;
  final ValueChanged<VigilTab> onTabSelected;
  final bool hasCrisisActive;

  const VigilBottomNav({
    super.key,
    required this.current,
    required this.onTabSelected,
    this.hasCrisisActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final hasUnreadAlerts = unreadCount > 0;
    final role = ref.watch(authProvider).role;

    List<VigilTab> tabs;
    if (role == UserRole.manager) {
      tabs = [VigilTab.dashboard, VigilTab.warRoom, VigilTab.map, VigilTab.notifications, VigilTab.profile];
    } else if (role == UserRole.staff) {
      tabs = [VigilTab.myTasks, VigilTab.warRoom, VigilTab.map, VigilTab.notifications, VigilTab.profile];
    } else {
      tabs = [VigilTab.guestHome, VigilTab.notifications, VigilTab.profile];
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: tabs.map((tab) {
              return Expanded(child: _NavItem(
                tab: tab,
                isSelected: current == tab,
                hasCrisisActive: hasCrisisActive && (tab == VigilTab.dashboard || tab == VigilTab.myTasks),
                hasUnreadAlerts: hasUnreadAlerts && tab == VigilTab.notifications,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTabSelected(tab);
                },
              ));
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final VigilTab tab;
  final bool isSelected;
  final bool hasCrisisActive;
  final bool hasUnreadAlerts;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.hasCrisisActive,
    this.hasUnreadAlerts = false,
    required this.onTap,
  });

  IconData get _icon {
    switch (tab) {
      case VigilTab.dashboard:
        return Icons.dashboard_outlined;
      case VigilTab.warRoom:
        return Icons.crisis_alert_outlined;
      case VigilTab.map:
        return Icons.map_outlined;
      case VigilTab.notifications:
        return Icons.notifications_outlined;
      case VigilTab.profile:
        return Icons.person_outline;
      case VigilTab.myTasks:
        return Icons.check_circle_outline;
      case VigilTab.guestHome:
        return Icons.home_outlined;
    }
  }

  IconData get _iconSelected {
    switch (tab) {
      case VigilTab.dashboard:
        return Icons.dashboard;
      case VigilTab.warRoom:
        return Icons.crisis_alert;
      case VigilTab.map:
        return Icons.map;
      case VigilTab.notifications:
        return Icons.notifications;
      case VigilTab.profile:
        return Icons.person;
      case VigilTab.myTasks:
        return Icons.check_circle;
      case VigilTab.guestHome:
        return Icons.home;
    }
  }

  String get _label {
    switch (tab) {
      case VigilTab.dashboard:
        return 'Dashboard';
      case VigilTab.warRoom:
        return 'War Room';
      case VigilTab.map:
        return 'Floor Map';
      case VigilTab.notifications:
        return 'Alerts';
      case VigilTab.profile:
        return 'Profile';
      case VigilTab.myTasks:
        return 'My Tasks';
      case VigilTab.guestHome:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.statusTeal : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(isSelected ? _iconSelected : _icon, color: color, size: 22),
              if (hasCrisisActive || hasUnreadAlerts)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.crisisRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
            child: Text(_label),
          ),
        ],
      ),
    );
  }
}
