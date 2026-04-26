import 'package:cloud_firestore/cloud_firestore.dart';

enum SensorStatus { normal, warning, alert, offline }

class SensorData {
  final String id;
  final String label;
  final String room;
  final double rx;
  final double ry;
  final SensorStatus status;

  const SensorData({
    required this.id,
    required this.label,
    required this.room,
    required this.rx,
    required this.ry,
    required this.status,
  });

  factory SensorData.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SensorData(
      id: doc.id,
      label: d['label'] as String? ?? 'Sensor',
      room: d['room'] as String? ?? 'Unknown',
      rx: (d['rx'] as num?)?.toDouble() ?? 0.0,
      ry: (d['ry'] as num?)?.toDouble() ?? 0.0,
      status: _statusFromString(d['status'] as String? ?? 'normal'),
    );
  }

  static SensorStatus _statusFromString(String s) {
    switch (s) {
      case 'warning':
        return SensorStatus.warning;
      case 'alert':
        return SensorStatus.alert;
      case 'offline':
        return SensorStatus.offline;
      default:
        return SensorStatus.normal;
    }
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'room': room,
        'rx': rx,
        'ry': ry,
        'status': status.name,
      };
}
