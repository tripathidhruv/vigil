import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/incident_card.dart';
import '../../core/widgets/staff_chip.dart';
import '../../core/animations/severity_pulse_badge.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class HotelStats {
  final int activeIncidents;
  final int staffOnDuty;
  final int resolvedToday;
  final int avgResponseMin;
  final bool hasCrisis;

  const HotelStats({
    required this.activeIncidents,
    required this.staffOnDuty,
    required this.resolvedToday,
    required this.avgResponseMin,
    required this.hasCrisis,
  });
}

class StaffMember {
  final String name;
  final String role;
  final StaffStatus status;

  const StaffMember(this.name, this.role, this.status);
}

// ── Mock data ─────────────────────────────────────────────────────────────────

const List<IncidentModel> kMockIncidents = [
  IncidentModel(
    id: 'INC-001',
    title: 'Kitchen Fire — Suppression Activated',
    location: 'Floor 2 · Main Kitchen',
    timeAgo: '8m ago',
    severity: CrisisSeverity.critical,
    assignedCount: 4,
    isActive: true,
  ),
  IncidentModel(
    id: 'INC-002',
    title: 'Guest Medical Emergency',
    location: 'Floor 5 · Room 514',
    timeAgo: '22m ago',
    severity: CrisisSeverity.high,
    assignedCount: 2,
    isActive: true,
  ),
  IncidentModel(
    id: 'INC-003',
    title: 'Elevator Malfunction — Guests Trapped',
    location: 'North Tower · Elevator 3',
    timeAgo: '1h 4m ago',
    severity: CrisisSeverity.moderate,
    assignedCount: 3,
    isActive: false,
  ),
];

const List<StaffMember> kMockStaff = [
  StaffMember('James Harrington', 'General Manager', StaffStatus.available),
  StaffMember('Sarah Chen', 'Security Chief', StaffStatus.onScene),
  StaffMember('David Okafor', 'Front Desk', StaffStatus.available),
  StaffMember('Maria Santos', 'F&B Manager', StaffStatus.onScene),
  StaffMember('Raj Patel', 'Engineering', StaffStatus.available),
  StaffMember('Liu Wei', 'Housekeeping', StaffStatus.offDuty),
];

// ── Providers ─────────────────────────────────────────────────────────────────

final hotelStatsProvider = Provider<HotelStats>((ref) {
  return const HotelStats(
    activeIncidents: 2,
    staffOnDuty: 14,
    resolvedToday: 5,
    avgResponseMin: 4,
    hasCrisis: true,
  );
});

final staffListProvider = Provider<List<StaffMember>>((ref) => kMockStaff);

final incidentListProvider =
    Provider<List<IncidentModel>>((ref) => kMockIncidents);
