import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/incident_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class CommandState {
  final int timerSeconds;
  final bool isAllClear;

  const CommandState({
    this.timerSeconds = 0,
    this.isAllClear = false,
  });

  CommandState copyWith({
    int? timerSeconds,
    bool? isAllClear,
  }) =>
      CommandState(
        timerSeconds: timerSeconds ?? this.timerSeconds,
        isAllClear: isAllClear ?? this.isAllClear,
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

class CommandNotifier extends StateNotifier<CommandState> {
  final FirebaseService _firebaseService;
  Timer? _timer;
  DateTime? _startTime;

  CommandNotifier(this._firebaseService) : super(const CommandState());

  void initTimer(DateTime startTime) {
    _startTime = startTime;
    _timer?.cancel();
    
    final diff = DateTime.now().difference(startTime).inSeconds;
    state = state.copyWith(timerSeconds: diff > 0 ? diff : 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final currentDiff = DateTime.now().difference(_startTime!).inSeconds;
      state = state.copyWith(timerSeconds: currentDiff > 0 ? currentDiff : 0);
    });
  }

  Future<void> declareAllClear(String incidentId) async {
    _timer?.cancel();
    state = state.copyWith(isAllClear: true);
    await _firebaseService.updateIncidentStatus(incidentId, 'resolved');
  }

  Future<void> assignStaff(String incidentId, String uid) async {
    await _firebaseService.assignStaffToIncident(incidentId, uid);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final commandProvider = StateNotifierProvider<CommandNotifier, CommandState>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return CommandNotifier(fbService);
});

// Provides the stream of the specific active incident
final activeIncidentProvider = StreamProvider.family<IncidentModel?, String>((ref, incidentId) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamIncident(incidentId);
});

// Provides all users to map assignedTo IDs to actual names and roles
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamAllStaff();
});
