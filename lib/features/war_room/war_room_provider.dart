import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../auth/auth_provider.dart';

// Legacy / mock types requested to fix compilation
enum MessageType { user, system, ai, staff }

class WarRoomMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;
  final MessageType type;

  const WarRoomMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.type,
  });

  // Mappers for the new model if needed by other parts of the app
  String get content => text;
  String get senderName => sender;
  String get timeStr {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory WarRoomMessage.fromFirestore(var doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WarRoomMessage(
      id: doc.id,
      text: d['text'] as String? ?? d['content'] as String? ?? '',
      sender: d['sender'] as String? ?? d['senderName'] as String? ?? 'Unknown',
      timestamp: (d['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      type: _typeFromString(d['type'] as String?),
    );
  }

  static MessageType _typeFromString(String? t) {
    switch (t) {
      case 'system': return MessageType.system;
      case 'ai': return MessageType.ai;
      case 'staff': return MessageType.staff;
      default: return MessageType.user;
    }
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'sender': sender,
        'timestamp': timestamp,
        'type': type.name,
        // Also provide new fields to be backwards compatible
        'content': text,
        'senderName': sender,
      };

  WarRoomMessage copyWith({
    String? id,
    String? text,
    String? sender,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return WarRoomMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

typedef WarMessage = WarRoomMessage;

// Stream of messages for a specific incident
final warRoomMessagesProvider = StreamProvider.family<List<WarRoomMessage>, String>((ref, incidentId) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamWarRoomMessages(incidentId);
});

class WarRoomNotifier {
  final FirebaseService _firebaseService;
  final Ref _ref;

  WarRoomNotifier(this._firebaseService, this._ref);

  Future<void> sendMessage(String incidentId, String content) async {
    if (content.trim().isEmpty) return;

    final authState = _ref.read(authProvider);
    final user = authState.user;

    if (user == null) return;

    final msg = WarRoomMessage(
      id: '', // Firestore generated
      sender: user.name,
      text: content.trim(),
      timestamp: DateTime.now(),
      type: MessageType.staff,
    );

    await _firebaseService.sendWarRoomMessage(incidentId, msg);
  }
}

final warRoomActionProvider = Provider<WarRoomNotifier>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return WarRoomNotifier(fbService, ref);
});

// Legacy Provider to fix compilation
class MockWarRoomNotifier extends StateNotifier<List<WarRoomMessage>> {
  MockWarRoomNotifier() : super([]);
  void send(String text, String sender) {}
}

final warRoomProvider = StateNotifierProvider<MockWarRoomNotifier, List<WarRoomMessage>>((ref) {
  return MockWarRoomNotifier();
});
