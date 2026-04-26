import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/incident_model.dart';
import '../../services/firebase_service.dart';
import '../auth/auth_provider.dart';

final staffAssignedIncidentsProvider = StreamProvider<List<IncidentModel>>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  
  if (user == null) {
    return Stream.value([]);
  }

  final fbService = ref.watch(firebaseProvider);
  return fbService.streamAssignedIncidents(user.uid);
});

class StaffActionNotifier {
  final FirebaseService _firebaseService;
  
  StaffActionNotifier(this._firebaseService);

  Future<void> markIncidentComplete(String incidentId) async {
    await _firebaseService.resolveIncident(incidentId);
  }

  Future<void> toggleAvailability(String uid, bool isCurrentlyOnDuty) async {
    await _firebaseService.updateUserStatus(uid, !isCurrentlyOnDuty);
  }
}

final staffActionProvider = Provider<StaffActionNotifier>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return StaffActionNotifier(fbService);
});

// Legacy Provider to fix compilation
class MockStaffState {
  final bool isAvailable;
  const MockStaffState({this.isAvailable = true});
}

class MockStaffNotifier extends StateNotifier<MockStaffState> {
  MockStaffNotifier() : super(const MockStaffState());
  void toggleAvailability() => state = MockStaffState(isAvailable: !state.isAvailable);
}

final staffProvider = StateNotifierProvider<MockStaffNotifier, MockStaffState>((ref) {
  return MockStaffNotifier();
});
