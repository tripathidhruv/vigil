import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/animations/severity_pulse_badge.dart';
import '../../services/gemini_service.dart';

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

enum DrillPhase { selecting, active, completed, generating_feedback }

class DrillState {
  final DrillPhase phase;
  final DrillScenario? scenario;
  final int timerSeconds;
  final int score;
  final String feedback;
  final String currentEvent;
  final String? errorMessage;

  const DrillState({
    this.phase = DrillPhase.selecting,
    this.scenario,
    this.timerSeconds = 0,
    this.score = 0,
    this.feedback = '',
    this.currentEvent = '',
    this.errorMessage,
  });

  DrillState copyWith({
    DrillPhase? phase,
    DrillScenario? scenario,
    int? timerSeconds,
    int? score,
    String? feedback,
    String? currentEvent,
    String? errorMessage,
  }) =>
      DrillState(
        phase: phase ?? this.phase,
        scenario: scenario ?? this.scenario,
        timerSeconds: timerSeconds ?? this.timerSeconds,
        score: score ?? this.score,
        feedback: feedback ?? this.feedback,
        currentEvent: currentEvent ?? this.currentEvent,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DrillNotifier extends StateNotifier<DrillState> {
  final GeminiService _geminiService;

  DrillNotifier(this._geminiService) : super(const DrillState());

  Timer? _timer;

  void startDrill(DrillScenario scenario) {
    state = DrillState(
      phase: DrillPhase.active,
      scenario: scenario,
      currentEvent: 'Simulation initialized...',
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      
      final nextSec = state.timerSeconds + 1;
      if (nextSec >= 30) {
        completeDrill();
        return;
      }

      String event = state.currentEvent;
      if (nextSec == 5) event = 'First responders dispatched...';
      if (nextSec == 12) event = 'On-site containment initiated...';
      if (nextSec == 20) event = 'Evacuation protocols active...';
      if (nextSec == 26) event = 'Securing area for final assessment...';

      state = state.copyWith(timerSeconds: nextSec, currentEvent: event);
    });
  }

  Future<void> completeDrill() async {
    if (state.phase == DrillPhase.generating_feedback || state.phase == DrillPhase.completed) return;
    _timer?.cancel();
    state = state.copyWith(phase: DrillPhase.generating_feedback);
    
    try {
      final target = (state.scenario?.durationMin ?? 10) * 60;
      final actual = state.timerSeconds;
      final ratio = actual / target;
      
      int score = 100;
      List<String> issues = [];

      if (ratio > 1.0) {
        score = 85;
        issues.add('Target resolution time exceeded by ${actual - target} seconds');
      }
      if (ratio > 1.2) {
        score = 70;
        issues.add('Significant delay in final containment');
      }
      if (ratio > 1.5) {
        score = 55;
        issues.add('Critically slow response time, high risk of escalation');
      }

      final feedback = await _geminiService.generateDrillFeedback(
        score, 
        state.scenario?.title ?? 'Unknown Drill', 
        issues.isEmpty ? ['Perfect execution, no major issues noted.'] : issues
      );

      state = state.copyWith(
        phase: DrillPhase.completed,
        score: score,
        feedback: feedback,
      );
    } catch (e) {
      state = state.copyWith(
        phase: DrillPhase.completed,
        score: 0,
        errorMessage: 'Failed to generate feedback: $e',
        feedback: 'Drill complete. System error preventing AI feedback generation.',
      );
    }
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

final drillProvider = StateNotifierProvider<DrillNotifier, DrillState>((ref) {
  final geminiService = ref.watch(geminiProvider);
  return DrillNotifier(geminiService);
});
