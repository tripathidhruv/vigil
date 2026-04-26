import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ───────────────────────────────────────────────────────────────────

enum SensorStatus { normal, warning, alert, offline }

class SensorData {
  final String id;
  final String label;
  final String room;
  // Relative positions (0.0–1.0 of canvas)
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
}

// ── Mock data ─────────────────────────────────────────────────────────────────

const List<SensorData> kFloorSensors = [
  SensorData(id: 's1', label: 'Smoke', room: 'Kitchen', rx: 0.70, ry: 0.28, status: SensorStatus.alert),
  SensorData(id: 's2', label: 'Heat', room: 'Kitchen', rx: 0.82, ry: 0.32, status: SensorStatus.alert),
  SensorData(id: 's3', label: 'Smoke', room: 'Lobby', rx: 0.22, ry: 0.55, status: SensorStatus.normal),
  SensorData(id: 's4', label: 'Motion', room: 'Corridor A', rx: 0.45, ry: 0.50, status: SensorStatus.normal),
  SensorData(id: 's5', label: 'Smoke', room: 'Room 101', rx: 0.20, ry: 0.28, status: SensorStatus.normal),
  SensorData(id: 's6', label: 'Smoke', room: 'Room 102', rx: 0.38, ry: 0.28, status: SensorStatus.normal),
  SensorData(id: 's7', label: 'CO2', room: 'Corridor B', rx: 0.55, ry: 0.72, status: SensorStatus.warning),
  SensorData(id: 's8', label: 'Door', room: 'Fire Exit', rx: 0.88, ry: 0.68, status: SensorStatus.offline),
];

// ── Provider ──────────────────────────────────────────────────────────────────

final floorSensorsProvider = Provider<List<SensorData>>((ref) => kFloorSensors);
