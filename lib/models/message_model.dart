import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { staff, system, ai }

class WarRoomMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  const WarRoomMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.staff,
  });

  factory WarRoomMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WarRoomMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      senderName: d['senderName'] as String? ?? 'Unknown',
      content: d['content'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: _typeFromString(d['type'] as String? ?? 'staff'),
    );
  }

  static MessageType _typeFromString(String t) {
    switch (t) {
      case 'system':
        return MessageType.system;
      case 'ai':
        return MessageType.ai;
      default:
        return MessageType.staff;
    }
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'timestamp': Timestamp.fromDate(timestamp),
        'type': type.name,
      };

  String get timeStr {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
