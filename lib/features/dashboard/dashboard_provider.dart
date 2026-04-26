import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/incident_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

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

// ── Providers ─────────────────────────────────────────────────────────────────

final incidentListProvider = StreamProvider<List<IncidentModel>>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamActiveIncidents();
});

final incidentByIdProvider = Provider.family<IncidentModel?, String>((ref, id) {
  return ref.watch(allIncidentsProvider).whenData((list) => 
    list.cast<IncidentModel?>().firstWhere((i) => i?.id == id, orElse: () => null)
  ).value;
});

final recentIncidentsProvider = StreamProvider<List<IncidentModel>>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamRecentIncidents();
});

final staffListProvider = StreamProvider<List<UserModel>>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamStaffOnDuty();
});

final allIncidentsProvider = StreamProvider<List<IncidentModel>>((ref) {
  final fbService = ref.watch(firebaseProvider);
  return fbService.streamAllIncidents();
});

final hotelStatsProvider = Provider<AsyncValue<HotelStats>>((ref) {
  final incidentsAsync = ref.watch(allIncidentsProvider);
  final staffAsync = ref.watch(staffListProvider);

  if (incidentsAsync.isLoading || staffAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (incidentsAsync.hasError) {
    return AsyncValue.error(incidentsAsync.error!, incidentsAsync.stackTrace!);
  }

  final allDocs = incidentsAsync.value ?? [];
  final staffList = staffAsync.value ?? [];

  int active = 0;
  int resolvedToday = 0;
  int totalTime = 0;
  int resolvedCount = 0;
  final now = DateTime.now();

  for (var incident in allDocs) {
    if (incident.isActive) {
      active++;
    } else if (incident.status == 'resolved') {
      if (now.difference(incident.timestamp).inHours < 24) {
        resolvedToday++;
      }
      resolvedCount++;
      totalTime += 4; 
    }
  }

  final avg = resolvedCount > 0 ? (totalTime / resolvedCount).round() : 0;

  return AsyncValue.data(HotelStats(
    activeIncidents: active,
    staffOnDuty: staffList.length,
    resolvedToday: resolvedToday,
    avgResponseMin: avg,
    hasCrisis: active > 0,
  ));
});
