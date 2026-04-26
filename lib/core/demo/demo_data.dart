import '../../models/incident_model.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../features/war_room/war_room_provider.dart';
import '../../features/floor_map/floor_map_provider.dart';
import '../../features/dashboard/dashboard_provider.dart';
import '../../features/analytics/analytics_provider.dart'; // Ensure AnalyticsData is imported if exists, otherwise create it.

// AnalyticsData model definition (if it doesn't exist, I'll add it here for simplicity, but it should be in analytics_provider.dart)
// Let's assume it exists in analytics_provider.dart, if not we will resolve it.

// 3 Active Incidents
final demoIncidents = [
  IncidentModel(
    id: 'inc_001',
    type: 'Fire',
    location: 'Kitchen - Floor 2',
    severity: 3,
    status: 'active',
    reportedBy: 'staff_001',
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    assignedTo: ['staff_001', 'staff_002'],
    notes: 'Smoke detected near stove area. Fire suppression activated.',
  ),
  IncidentModel(
    id: 'inc_002',
    type: 'Medical',
    location: 'Room 412',
    severity: 2,
    status: 'active',
    reportedBy: 'staff_003',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    assignedTo: ['staff_003'],
    notes: 'Guest reported chest pain. Paramedics called.',
  ),
  IncidentModel(
    id: 'inc_003',
    type: 'Security',
    location: 'Lobby - Main Entrance',
    severity: 1,
    status: 'active',
    reportedBy: 'staff_002',
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    assignedTo: [],
    notes: 'Unauthorized individual detected near reception.',
  ),
];

// Staff Members
final demoStaff = [
  const UserModel(uid: 'staff_001', name: 'James Harrington', department: 'Security', onDuty: true, role: 'staff', email: 'staff1@vigil.com'),
  const UserModel(uid: 'staff_002', name: 'Maria Santos', department: 'Housekeeping', onDuty: true, role: 'staff', email: 'staff2@vigil.com'),
  const UserModel(uid: 'staff_003', name: 'Raj Patel', department: 'Medical', onDuty: true, role: 'staff', email: 'staff3@vigil.com'),
  const UserModel(uid: 'staff_004', name: 'Lucy Chen', department: 'Front Desk', onDuty: false, role: 'staff', email: 'staff4@vigil.com'),
];

// War Room Messages
final demoMessages = [
  WarRoomMessage(id: 'm1', text: 'CRISIS ACTIVATED — Kitchen Fire Floor 2', sender: 'SYSTEM', type: MessageType.system, timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
  WarRoomMessage(id: 'm2', text: 'Fire suppression system triggered automatically', sender: 'AI VIGIL', type: MessageType.ai, timestamp: DateTime.now().subtract(const Duration(minutes: 11))),
  WarRoomMessage(id: 'm3', text: 'On my way to Floor 2 now', sender: 'James Harrington', type: MessageType.user, timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
  WarRoomMessage(id: 'm4', text: 'Fire brigade contacted. ETA 8 minutes', sender: 'Maria Santos', type: MessageType.user, timestamp: DateTime.now().subtract(const Duration(minutes: 8))),
  WarRoomMessage(id: 'm5', text: 'Guests on Floor 2 being evacuated to assembly point', sender: 'James Harrington', type: MessageType.user, timestamp: DateTime.now().subtract(const Duration(minutes: 6))),
  WarRoomMessage(id: 'm6', text: 'Recommended: Evacuate floors 2-4 as precaution', sender: 'AI VIGIL', type: MessageType.ai, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
];

// Sensor Data for Floor Map
final demoSensors = [
  const SensorData(id: 's1', name: 'Kitchen Smoke', status: SensorStatus.alert, x: 0.3, y: 0.4, floor: 2),
  const SensorData(id: 's2', name: 'Lobby Temp', status: SensorStatus.normal, x: 0.5, y: 0.8, floor: 1),
  const SensorData(id: 's3', name: 'Room 412 Motion', status: SensorStatus.warning, x: 0.7, y: 0.3, floor: 4),
  const SensorData(id: 's4', name: 'Parking CCTV', status: SensorStatus.normal, x: 0.2, y: 0.9, floor: 0),
  const SensorData(id: 's5', name: 'Server Room Temp', status: SensorStatus.warning, x: 0.8, y: 0.6, floor: 1),
  const SensorData(id: 's6', name: 'Pool Area Motion', status: SensorStatus.offline, x: 0.6, y: 0.2, floor: 0),
];

// Notifications
final demoNotifications = [
  VigilNotification(id: 'n1', title: 'CRISIS: Kitchen Fire', body: 'Active crisis on Floor 2. Report to command center.', type: NotifType.crisis, timestamp: DateTime.now().subtract(const Duration(minutes: 12)), isRead: false),
  VigilNotification(id: 'n2', title: 'Medical Alert', body: 'Guest in Room 412 requires medical attention.', type: NotifType.alert, timestamp: DateTime.now().subtract(const Duration(minutes: 5)), isRead: false),
  VigilNotification(id: 'n3', title: 'Staff Update', body: 'James Harrington checked in for duty.', type: NotifType.staff, timestamp: DateTime.now().subtract(const Duration(hours: 1)), isRead: true),
  VigilNotification(id: 'n4', title: 'System', body: 'Daily drill scheduled for 15:00 today.', type: NotifType.system, timestamp: DateTime.now().subtract(const Duration(hours: 2)), isRead: true),
];

// Hotel Stats
const demoHotelStats = HotelStats(
  hasCrisis: true,
  activeIncidents: 3,
  staffOnDuty: 3,
  resolvedToday: 5,
  avgResponseMin: 4,
);

// Analytics
const demoAnalytics = AnalyticsData(
  incidentsByType: [
    BarStat('Fire', 8, 'red'),
    BarStat('Medical', 12, 'amber'),
    BarStat('Security', 6, 'blue'),
    BarStat('Flood', 2, 'teal'),
    BarStat('Other', 3, 'orange'),
  ],
  responseTimeTrend: [
    LineStat(0, 6.2),
    LineStat(1, 4.8),
    LineStat(2, 5.1),
    LineStat(3, 3.9),
    LineStat(4, 4.2),
    LineStat(5, 5.5),
    LineStat(6, 4.1),
  ],
  totalIncidents: 31,
  avgResponseMin: 4,
  resolutionRate: 90.3,
  insights: [
    'Medical incidents peaked on Tuesday.',
    'Overall response time improved by 12%.'
  ],
);
