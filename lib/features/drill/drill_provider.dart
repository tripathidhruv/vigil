import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/animations/severity_pulse_badge.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class DrillScenario {
  final String id;
  final String title;
  final String description;
  final String type;
  final CrisisSeverity severity;
  final int durationMin;

  const DrillScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.durationMin,
  });
}

const List<DrillScenario> kDrillScenarios = [
  DrillScenario(
    id: 'd1',
    title: 'Kitchen Fire Outbreak',
    description: 'Simulated grease fire in the main kitchen with suppression system failure.',
    type: 'Fire',
    severity: CrisisSeverity.critical,
    durationMin: 15,
  ),
  DrillScenario(
    id: 'd2',
    title: 'Guest Medical Emergency',
    description: 'Guest collapses in the lobby. First responder and emergency services drill.',
    type: 'Medical',
    severity: CrisisSeverity.high,
    durationMin: 10,
  ),
  DrillScenario(
    id: 'd3',
    title: 'Bomb Threat Evacuation',
    description: 'Anonymous threat received. Full hotel evacuation to muster point.',
    type: 'Security',
    severity: CrisisSeverity.critical,
    durationMin: 20,
  ),
  DrillScenario(
    id: 'd4',
    title: 'Flood — Lower Ground Level',
    description: 'Pipe burst in basement. Guest belongings and electrical systems at risk.',
    type: 'Flood',
    severity: CrisisSeverity.moderate,
    durationMin: 12,
  ),
];

enum DrillPhase { selecting, active, completed }

class DrillState {
  final DrillPhase phase;
  final DrillScenario? scenario;
  final int timerSeconds;
  final int score;
  final String feedback;

  const DrillState({
    this.phase = DrillPhase.selecting,
    this.scenario,
    this.timerSeconds = 0,
    this.score = 0,
    this.feedback = '',
  });

  DrillState copyWith({
    DrillPhase? phase,
    DrillScenario? scenario,
    int? timerSeconds,
    int? score,
    String? feedback,
  }) =>
      DrillState(
        phase: phase ?? this.phase,
        scenario: scenario ?? this.scenario,
        timerSeconds: timerSeconds ?? this.timerSeconds,
        score: score ?? this.score,
        feedback: feedback ?? this.feedback,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DrillNotifier extends StateNotifier<DrillState> {
  DrillNotifier() : super(const DrillState());

  Timer? _timer;

  void startDrill(DrillScenario scenario) {
    state = DrillState(phase: DrillPhase.active, scenario: scenario);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      state = state.copyWith(timerSeconds: state.timerSeconds + 1);
    });
  }

  Future<void> completeDrill() async {
    _timer?.cancel();
    state = state.copyWith(phase: DrillPhase.completed);
    await Future.delayed(const Duration(milliseconds: 800));
    // Calculate score based on time vs target
    final target = (state.scenario?.durationMin ?? 10) * 60;
    final actual = state.timerSeconds;
    final ratio = actual / target;
    final score = ratio <= 1.0
        ? 100
        : ratio <= 1.2
            ? 85
            : ratio <= 1.5
                ? 70
                : 55;
    const feedback =
        'Good response time. Communication between departments was effective. '
        'Consider pre-assigning roles before drills. Fire safety team was '
        'well-coordinated. Recommended: repeat in 30 days.';
    state = state.copyWith(score: score, feedback: feedback);
  }

  void reset() {
    _timer?.cancel();
    state = const DrillState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final drillProvider =
    StateNotifierProvider<DrillNotifier, DrillState>((ref) => DrillNotifier());
