import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// ── Models ───────────────────────────────────────────────────────────────────

enum MessageType { staff, system, ai }

class WarMessage {
  final String id;
  final String sender;
  final String content;
  final String timeStr;
  final MessageType type;

  const WarMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timeStr,
    required this.type,
  });
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WarRoomNotifier extends StateNotifier<List<WarMessage>> {
  WarRoomNotifier()
      : super([
          const WarMessage(
              id: 'm0',
              sender: 'VIGIL SYSTEM',
              content: 'Crisis activated — Kitchen Fire, Floor 2. INC-001 open.',
              timeStr: '18:01',
              type: MessageType.system),
          const WarMessage(
              id: 'm1',
              sender: 'GEMINI AI',
              content: 'Classification: CRITICAL · Fire. Recommended immediate response: evacuate affected floors, confirm suppression, contact Fire Brigade.',
              timeStr: '18:01',
              type: MessageType.ai),
          const WarMessage(
              id: 'm2',
              sender: 'Sarah Chen',
              content: 'On scene. Suppression activated. Floor 2 being evacuated.',
              timeStr: '18:03',
              type: MessageType.staff),
          const WarMessage(
              id: 'm3',
              sender: 'Raj Patel',
              content: 'Engineering here — checking gas shutoff now.',
              timeStr: '18:04',
              type: MessageType.staff),
          const WarMessage(
              id: 'm4',
              sender: 'James Harrington',
              content: 'Fire Brigade ETA 6 minutes. Keep evacuation route clear.',
              timeStr: '18:05',
              type: MessageType.staff),
        ]);

  static const _uuid = Uuid();

  void send(String content, String senderName) {
    if (content.trim().isEmpty) return;
    final now = DateFormat('HH:mm').format(DateTime.now());
    state = [
      ...state,
      WarMessage(
        id: _uuid.v4(),
        sender: senderName,
        content: content.trim(),
        timeStr: now,
        type: MessageType.staff,
      ),
    ];
  }
}

final warRoomProvider = StateNotifierProvider<WarRoomNotifier, List<WarMessage>>(
    (ref) => WarRoomNotifier());
