import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/animations/severity_pulse_badge.dart';
import '../../core/widgets/staff_chip.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class AssignedStaff {
  final String name;
  final String role;
  final StaffStatus status;
  final String task;

  const AssignedStaff({
    required this.name,
    required this.role,
    required this.status,
    required this.task,
  });
}

class CommandState {
  final String incidentId;
  final String title;
  final String location;
  final CrisisSeverity severity;
  final int timerSeconds;
  final bool isAllClear;
  final List<AssignedStaff> assignedStaff;

  const CommandState({
    this.incidentId = 'INC-001',
    this.title = 'Kitchen Fire — Suppression Activated',
    this.location = 'Floor 2 · Main Kitchen',
    this.severity = CrisisSeverity.critical,
    this.timerSeconds = 0,
    this.isAllClear = false,
    this.assignedStaff = const [],
  });

  CommandState copyWith({
    String? incidentId,
    String? title,
    String? location,
    CrisisSeverity? severity,
    int? timerSeconds,
    bool? isAllClear,
    List<AssignedStaff>? assignedStaff,
  }) =>
      CommandState(
        incidentId: incidentId ?? this.incidentId,
        title: title ?? this.title,
        location: location ?? this.location,
        severity: severity ?? this.severity,
        timerSeconds: timerSeconds ?? this.timerSeconds,
        isAllClear: isAllClear ?? this.isAllClear,
        assignedStaff: assignedStaff ?? this.assignedStaff,
      );

  String get timerFormatted {
    final h = timerSeconds ~/ 3600;
    final m = (timerSeconds % 3600) ~/ 60;
    final s = timerSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

const List<AssignedStaff> _kDefaultStaff = [
  AssignedStaff(
      name: 'Sarah Chen',
      role: 'Security Chief',
      status: StaffStatus.onScene,
      task: 'Floor evacuation lead'),
  AssignedStaff(
      name: 'Raj Patel',
      role: 'Engineering',
      status: StaffStatus.onScene,
      task: 'Suppression system check'),
  AssignedStaff(
      name: 'David Okafor',
      role: 'Front Desk',
      status: StaffStatus.available,
      task: 'Guest communication'),
  AssignedStaff(
      name: 'Maria Santos',
      role: 'F&B Manager',
      status: StaffStatus.onScene,
      task: 'Kitchen area control'),
];

// ── Notifier ──────────────────────────────────────────────────────────────────

class CommandNotifier extends StateNotifier<CommandState> {
  CommandNotifier()
      : super(const CommandState(assignedStaff: _kDefaultStaff)) {
    _startTimer();
  }

  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      state = state.copyWith(timerSeconds: state.timerSeconds + 1);
    });
  }

  void declareAllClear() {
    _timer?.cancel();
    state = state.copyWith(isAllClear: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final commandProvider =
    StateNotifierProvider<CommandNotifier, CommandState>(
        (ref) => CommandNotifier());
