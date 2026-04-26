import 'package:cloud_firestore/cloud_firestore.dart';

enum NotifType { crisis, staff, system, alert }

class VigilNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotifType type;
  final bool isRead;
  final String? incidentId;

  const VigilNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.incidentId,
  });

  factory VigilNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VigilNotification(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: _typeFromString(d['type'] as String? ?? 'system'),
      isRead: d['isRead'] as bool? ?? false,
      incidentId: d['incidentId'] as String?,
    );
  }

  static NotifType _typeFromString(String t) {
    switch (t) {
      case 'crisis':
        return NotifType.crisis;
      case 'staff':
        return NotifType.staff;
      case 'alert':
        return NotifType.alert;
      default:
        return NotifType.system;
    }
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'timestamp': Timestamp.fromDate(timestamp),
        'type': type.name,
        'isRead': isRead,
        'incidentId': incidentId,
      };

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  VigilNotification copyWith({bool? isRead}) => VigilNotification(
        id: id,
        title: title,
        body: body,
        timestamp: timestamp,
        type: type,
        isRead: isRead ?? this.isRead,
        incidentId: incidentId,
      );
}
