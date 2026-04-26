import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';
import '../features/war_room/war_room_provider.dart';
import '../features/floor_map/floor_map_provider.dart';
import '../models/notification_model.dart';
import '../core/demo/demo_data.dart';

final firebaseProvider = Provider<FirebaseService>((ref) => FirebaseService());

class FirebaseService {
  // Demo State
  List<IncidentModel> _incidents = List.of(demoIncidents);
  List<WarRoomMessage> _messages = List.of(demoMessages);
  List<VigilNotification> _notifications = List.of(demoNotifications);
  List<UserModel> _staff = List.of(demoStaff);

  // Controllers
  final _incidentsCtrl = StreamController<List<IncidentModel>>.broadcast();
  final _messagesCtrl = StreamController<List<WarRoomMessage>>.broadcast();
  final _notificationsCtrl = StreamController<List<VigilNotification>>.broadcast();
  final _staffCtrl = StreamController<List<UserModel>>.broadcast();

  FirebaseService() {
    // Initial emit
    Future.microtask(() {
      _incidentsCtrl.add(List.of(_incidents));
      _messagesCtrl.add(List.of(_messages));
      _notificationsCtrl.add(List.of(_notifications));
      _staffCtrl.add(List.of(_staff));
    });
  }

  IncidentModel? getIncidentById(String id) {
    try {
      return _incidents.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  void _emitIncidents() {
    _incidentsCtrl.add(List.of(_incidents));
  }

  // ── Incidents ──────────────────────────────────────────────────────────────

  Stream<List<IncidentModel>> streamAllIncidents() async* {
    yield _incidents;
    yield* _incidentsCtrl.stream;
  }

  Stream<List<IncidentModel>> streamActiveIncidents() async* {
    yield _incidents.where((i) => i.status == 'active' || i.status == 'acknowledged').toList();
    yield* _incidentsCtrl.stream.map((list) => 
        list.where((i) => i.status == 'active' || i.status == 'acknowledged').toList());
  }

  Stream<List<IncidentModel>> streamRecentIncidents({int limit = 10}) async* {
    final sorted = List<IncidentModel>.from(_incidents)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    yield sorted.take(limit).toList();

    yield* _incidentsCtrl.stream.map((list) {
      final s = List<IncidentModel>.from(list)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return s.take(limit).toList();
    });
  }

  Stream<IncidentModel?> streamIncident(String incidentId) async* {
    yield getIncidentById(incidentId);
    yield* _incidentsCtrl.stream.map((list) => 
        list.cast<IncidentModel?>().firstWhere((i) => i?.id == incidentId, orElse: () => null));
  }

  Stream<List<IncidentModel>> streamAssignedIncidents(String uid) async* {
    yield _incidents.where((i) => i.assignedTo.contains(uid) && (i.status == 'active' || i.status == 'acknowledged')).toList();
    yield* _incidentsCtrl.stream.map((list) => 
        list.where((i) => i.assignedTo.contains(uid) && (i.status == 'active' || i.status == 'acknowledged')).toList());
  }

  Future<String> createIncident(IncidentModel incident) async {
    final newId = 'inc_${DateTime.now().millisecondsSinceEpoch}';
    final newIncident = incident.copyWith(status: 'active');
    // Using copyWith is not possible if id is immutable without a copyWith parameter, let's assume it has no copyWith for ID.
    // Wait, incident_model.dart doesn't have copyWith(id: ...). We'll just create a new one:
    final actualNew = IncidentModel(
      id: newId,
      type: newIncident.type,
      location: newIncident.location,
      severity: newIncident.severity,
      status: 'active',
      reportedBy: newIncident.reportedBy,
      timestamp: newIncident.timestamp,
      assignedTo: newIncident.assignedTo,
      notes: newIncident.notes,
      description: newIncident.description,
    );
    _incidents.insert(0, actualNew);
    _emitIncidents();
    return newId;
  }

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    _incidents = _incidents.map((i) => 
      i.id == incidentId ? i.copyWith(status: status) : i
    ).toList();
    _emitIncidents();
  }

  Future<void> assignStaffToIncident(String incidentId, String uid) async {
    _incidents = _incidents.map((i) {
      if (i.id == incidentId) {
        final updatedList = List<String>.from(i.assignedTo);
        if (!updatedList.contains(uid)) updatedList.add(uid);
        return i.copyWith(assignedTo: updatedList);
      }
      return i;
    }).toList();
    _emitIncidents();
  }

  Future<void> resolveIncident(String incidentId) async {
    for (int i = 0; i < _incidents.length; i++) {
      if (_incidents[i].id == incidentId) {
        _incidents[i] = _incidents[i].copyWith(status: 'resolved');
        break;
      }
    }
    final activeOnly = _incidents.where((inc) => inc.status == 'active').toList();
    _incidentsCtrl.add(activeOnly);
  }

  // ── War Room Messages ──────────────────────────────────────────────────────

  Stream<List<WarRoomMessage>> streamWarRoomMessages(String incidentId) async* {
    yield _messages;
    yield* _messagesCtrl.stream;
  }

  Future<void> sendWarRoomMessage(String incidentId, WarRoomMessage message) async {
    _messages = [..._messages, message];
    _messagesCtrl.add(List.of(_messages));
  }

  // ── Users / Staff ──────────────────────────────────────────────────────────

  Stream<List<UserModel>> streamStaffOnDuty() async* {
    yield _staff.where((s) => s.onDuty).toList();
    yield* _staffCtrl.stream.map((list) => list.where((s) => s.onDuty).toList());
  }

  Stream<List<UserModel>> streamAllStaff() async* {
    yield _staff;
    yield* _staffCtrl.stream;
  }

  Future<UserModel?> getUser(String uid) async {
    return _staff.cast<UserModel?>().firstWhere((s) => s?.uid == uid, orElse: () => null);
  }

  Future<void> updateUserStatus(String uid, bool onDuty) async {
    _staff = _staff.map((s) => s.uid == uid ? s.copyWith(onDuty: onDuty) : s).toList();
    _staffCtrl.add(List.of(_staff));
  }

  // ── Sensors ────────────────────────────────────────────────────────────────

  Stream<List<SensorData>> streamSensors() {
    return Stream.value(demoSensors);
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  Stream<List<VigilNotification>> streamNotifications(String uid) async* {
    yield _notifications;
    yield* _notificationsCtrl.stream;
  }

  Future<void> markNotificationRead(String uid, String notificationId) async {
    _notifications = _notifications.map((n) => 
      n.id == notificationId ? n.copyWith(isRead: true) : n
    ).toList();
    _notificationsCtrl.add(List.of(_notifications));
  }

  Future<void> markAllNotificationsRead(String uid) async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notificationsCtrl.add(List.of(_notifications));
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    _notifications = _notifications.where((n) => n.id != notificationId).toList();
    _notificationsCtrl.add(List.of(_notifications));
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  Future<List<IncidentModel>> getAllIncidents() async {
    return _incidents;
  }
}
