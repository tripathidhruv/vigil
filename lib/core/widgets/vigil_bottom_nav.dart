import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

enum VigilTab { dashboard, warRoom, map, notifications, profile }

/// Custom bottom navigation bar for VIGIL manager screens.
class VigilBottomNav extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            children: VigilTab.values.map((tab) {
              return Expanded(child: _NavItem(
                tab: tab,
                isSelected: current == tab,
                hasCrisisActive: hasCrisisActive && tab == VigilTab.dashboard,
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
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.hasCrisisActive,
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
              if (hasCrisisActive)
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
