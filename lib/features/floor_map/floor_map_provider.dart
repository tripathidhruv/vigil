import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';

enum SensorStatus { normal, warning, alert, offline }

class SensorData {
  final String id;
  final String name;
  final SensorStatus status;
  final double x;
  final double y;
  final int floor;

  const SensorData({
    required this.id,
    required this.name,
    required this.status,
    required this.x,
    required this.y,
    required this.floor,
  });

  // Legacy mappings for UI compatibility
  String get label => name;
  String get room => 'Floor $floor';
  double get rx => x;
  double get ry => y;

  factory SensorData.fromFirestore(var doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SensorData(
      id: doc.id,
      name: d['label'] as String? ?? 'Sensor',
      status: _statusFromString(d['status'] as String? ?? 'normal'),
      x: (d['rx'] as num?)?.toDouble() ?? 0.0,
      y: (d['ry'] as num?)?.toDouble() ?? 0.0,
      floor: 2,
    );
  }

  static SensorStatus _statusFromString(String s) {
    switch (s) {
      case 'warning': return SensorStatus.warning;
      case 'alert': return SensorStatus.alert;
      case 'offline': return SensorStatus.offline;
      default: return SensorStatus.normal;
    }
  }

  Map<String, dynamic> toMap() => {
        'label': name,
        'rx': x,
        'ry': y,
        'status': status.name,
      };
}

final floorSensorsProvider = StreamProvider<List<SensorData>>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamSensors();
});
