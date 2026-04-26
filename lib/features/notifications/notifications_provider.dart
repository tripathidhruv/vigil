import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ───────────────────────────────────────────────────────────────────

enum NotifType { crisis, staff, system, alert }

class VigilNotification {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotifType type;
  final bool isRead;

  const VigilNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });

  VigilNotification copyWith({bool? isRead}) => VigilNotification(
        id: id,
        title: title,
        body: body,
        timeAgo: timeAgo,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}

// ── Mock data ─────────────────────────────────────────────────────────────────

final _kSeedNotifications = <VigilNotification>[
  const VigilNotification(
      id: 'n1',
      title: 'CRITICAL — Kitchen Fire Activated',
      body: 'INC-001 opened. 4 staff assigned. Suppression system active.',
      timeAgo: '8m ago',
      type: NotifType.crisis),
  const VigilNotification(
      id: 'n2',
      title: 'Staff Alert: Sarah Chen on scene',
      body: 'Security Chief has acknowledged assignment and is responding.',
      timeAgo: '9m ago',
      type: NotifType.staff),
  const VigilNotification(
      id: 'n3',
      title: 'Gemini AI: Playbook Generated',
      body: 'Response playbook for INC-001 is ready in Command Center.',
      timeAgo: '8m ago',
      type: NotifType.system),
  const VigilNotification(
      id: 'n4',
      title: 'Guest Alert Sent — Floor 2',
      body: 'Safety alert broadcasted to 14 guests in Hindi and English.',
      timeAgo: '12m ago',
      type: NotifType.alert),
  const VigilNotification(
      id: 'n5',
      title: 'Medical Emergency — Room 514',
      body: 'INC-002 opened. EMT dispatched. Status: responding.',
      timeAgo: '22m ago',
      type: NotifType.crisis),
  const VigilNotification(
      id: 'n6',
      title: 'Drill Reminder',
      body: 'Monthly fire drill scheduled for tomorrow at 10:00.',
      timeAgo: '2h ago',
      type: NotifType.system,
      isRead: true),
];

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<VigilNotification>> {
  NotificationsNotifier() : super(_kSeedNotifications);

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void markRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  String get unreadCount {
    final count = state.where((n) => !n.isRead).length;
    return count > 0 ? '$count' : '';
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<VigilNotification>>(
        (ref) => NotificationsNotifier());
