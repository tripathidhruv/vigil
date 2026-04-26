import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_model.dart';
import '../../services/firebase_service.dart';
import '../auth/auth_provider.dart';

final notificationsProvider = StreamProvider<List<VigilNotification>>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  
  if (user == null) {
    return Stream.value([]);
  }

  final fbService = ref.watch(firebaseProvider);
  return fbService.streamNotifications(user.uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

class NotificationsActionNotifier {
  final FirebaseService _firebaseService;
  final Ref _ref;

  NotificationsActionNotifier(this._firebaseService, this._ref);

  Future<void> markRead(String notificationId) async {
    final user = _ref.read(authProvider).user;
    if (user != null) {
      await _firebaseService.markNotificationRead(user.uid, notificationId);
    }
  }

  Future<void> markAllRead() async {
    final user = _ref.read(authProvider).user;
    if (user != null) {
      await _firebaseService.markAllNotificationsRead(user.uid);
    }
  }

  Future<void> dismiss(String notificationId) async {
    final user = _ref.read(authProvider).user;
    if (user != null) {
      await _firebaseService.deleteNotification(user.uid, notificationId);
    }
  }
}

final notificationsActionProvider = Provider<NotificationsActionNotifier>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return NotificationsActionNotifier(fbService, ref);
});
