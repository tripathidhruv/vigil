import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/animations/severity_pulse_badge.dart';

/// Unified incident model backed by Firestore.
class IncidentModel {
  final String id;
  final String type;       // Fire, Medical, Security, Flood, Power, Other
  final String location;   // "Floor 2 · Main Kitchen"
  final int severity;      // 1 = minor … 3 = critical
  final String status;     // active | acknowledged | resolved
  final String reportedBy; // uid
  final DateTime timestamp;
  final List<String> assignedTo; // uids
  final String notes;
  final String description;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.location,
    required this.severity,
    required this.status,
    required this.reportedBy,
    required this.timestamp,
    this.assignedTo = const [],
    this.notes = '',
    this.description = '',
  });

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return IncidentModel(
      id: doc.id,
      type: d['type'] as String? ?? 'Other',
      location: d['location'] as String? ?? '',
      severity: (d['severity'] as num?)?.toInt() ?? 1,
      status: d['status'] as String? ?? 'active',
      reportedBy: d['reportedBy'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedTo: List<String>.from(d['assignedTo'] ?? []),
      notes: d['notes'] as String? ?? '',
      description: d['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'location': location,
        'severity': severity,
        'status': status,
        'reportedBy': reportedBy,
        'timestamp': Timestamp.fromDate(timestamp),
        'assignedTo': assignedTo,
        'notes': notes,
        'description': description,
      };

  /// Human-readable title for UI display.
  String get title {
    switch (type) {
      case 'Fire':
        return 'Fire Emergency';
      case 'Medical':
        return 'Medical Emergency';
      case 'Security':
        return 'Security Incident';
      case 'Flood':
        return 'Flood / Water Damage';
      case 'Power':
        return 'Power Failure';
      case 'Earthquake':
        return 'Earthquake Alert';
      case 'Elevator':
        return 'Elevator Malfunction';
      default:
        return 'Incident — $type';
    }
  }

  /// How long ago relative to now.
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  int get assignedCount => assignedTo.length;

  CrisisSeverity get crisisSeverity {
    if (severity >= 3) return CrisisSeverity.critical;
    if (severity == 2) return CrisisSeverity.high;
    if (severity == 1) return CrisisSeverity.moderate;
    return CrisisSeverity.low;
  }

  bool get isActive => status == 'active' || status == 'acknowledged';

  IncidentModel copyWith({
    String? status,
    List<String>? assignedTo,
    String? notes,
  }) =>
      IncidentModel(
        id: id,
        type: type,
        location: location,
        severity: severity,
        status: status ?? this.status,
        reportedBy: reportedBy,
        timestamp: timestamp,
        assignedTo: assignedTo ?? this.assignedTo,
        notes: notes ?? this.notes,
        description: description,
      );
}
