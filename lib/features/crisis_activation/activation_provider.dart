import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ── Models ───────────────────────────────────────────────────────────────────

enum ActivationPhase { idle, analyzing, confirmed }

class PlaybookStep {
  final int step;
  final String action;
  final String owner;

  const PlaybookStep(this.step, this.action, this.owner);
}

class ActivationState {
  final ActivationPhase phase;
  final String incidentType;
  final String location;
  final String description;
  final String severity;
  final String incidentId;
  final List<PlaybookStep> playbook;

  const ActivationState({
    this.phase = ActivationPhase.idle,
    this.incidentType = '',
    this.location = '',
    this.description = '',
    this.severity = '',
    this.incidentId = '',
    this.playbook = const [],
  });

  ActivationState copyWith({
    ActivationPhase? phase,
    String? incidentType,
    String? location,
    String? description,
    String? severity,
    String? incidentId,
    List<PlaybookStep>? playbook,
  }) =>
      ActivationState(
        phase: phase ?? this.phase,
        incidentType: incidentType ?? this.incidentType,
        location: location ?? this.location,
        description: description ?? this.description,
        severity: severity ?? this.severity,
        incidentId: incidentId ?? this.incidentId,
        playbook: playbook ?? this.playbook,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ActivationNotifier extends StateNotifier<ActivationState> {
  ActivationNotifier() : super(const ActivationState());

  static const _uuid = Uuid();

  void setType(String type) => state = state.copyWith(incidentType: type);
  void setLocation(String loc) => state = state.copyWith(location: loc);
  void setDescription(String desc) => state = state.copyWith(description: desc);

  Future<void> analyzeAndActivate() async {
    state = state.copyWith(phase: ActivationPhase.analyzing);
    // Simulate Gemini classification (1 s) + playbook generation (1.5 s)
    await Future.delayed(const Duration(milliseconds: 1000));
    final sev = _classifyMock(state.incidentType);
    await Future.delayed(const Duration(milliseconds: 800));
    final playbook = _playbookMock(state.incidentType);
    state = state.copyWith(
      phase: ActivationPhase.confirmed,
      severity: sev,
      incidentId: _uuid.v4().substring(0, 8).toUpperCase(),
      playbook: playbook,
    );
  }

  void reset() => state = const ActivationState();

  String _classifyMock(String type) {
    const map = {
      'Fire': 'CRITICAL',
      'Medical': 'HIGH',
      'Security': 'HIGH',
      'Flood': 'MODERATE',
      'Power': 'MODERATE',
      'Earthquake': 'CRITICAL',
      'Elevator': 'LOW',
      'Other': 'MODERATE',
    };
    return map[type] ?? 'HIGH';
  }

  List<PlaybookStep> _playbookMock(String type) {
    const fire = [
      PlaybookStep(1, 'Evacuate affected floors via stairwells', 'Security'),
      PlaybookStep(2, 'Confirm suppression system activated; call Fire Brigade', 'Engineering'),
      PlaybookStep(3, 'Account for all guests — report to muster point', 'Front Desk'),
    ];
    const medical = [
      PlaybookStep(1, 'Dispatch first-responder to room immediately', 'Security'),
      PlaybookStep(2, 'Call emergency services (102)', 'Front Desk'),
      PlaybookStep(3, 'Clear elevator for paramedic access', 'Engineering'),
    ];
    if (type == 'Fire') return fire;
    if (type == 'Medical') return medical;
    return [
      PlaybookStep(1, 'Assess and contain the situation', 'Duty Manager'),
      PlaybookStep(2, 'Notify relevant departments', 'Front Desk'),
      PlaybookStep(3, 'Document and report to management', 'Security'),
    ];
  }
}

final activationProvider =
    StateNotifierProvider<ActivationNotifier, ActivationState>(
        (ref) => ActivationNotifier());
