import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiProvider = Provider<GeminiService>((ref) => GeminiService());

class GeminiService {
  Future<String> translateAlert(String text, String targetLanguage) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'URGENT: Alerte d\'urgence pour tous les clients. Veuillez suivre les instructions du personnel et vous diriger calmement vers la sortie la plus proche.';
  }

  Future<String> classifyIncident(String description) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return '{"type":"Fire","severity":"SEV-1","summary":"FIRE — Severity: HIGH — Recommended Response: Immediate evacuation of affected floors. Contact fire brigade. Activate suppression systems."}';
  }

  Future<String> generatePlaybook(String crisisType, String severity) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return '1. Evacuate all guests from affected area immediately\n2. Call emergency services\n3. Activate hotel emergency broadcast system\n4. Assign staff to evacuation routes\n5. Account for all guests at assembly point\n6. Do not allow re-entry until all-clear\n7. Document all actions with timestamps\n8. Notify hotel management and ownership';
  }

  Future<String> generateComplianceReport({
    required String incidentType,
    required String severity,
    required DateTime startTime,
    required DateTime resolvedTime,
    required String location,
    required String responseActions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return 'INCIDENT COMPLIANCE REPORT\n\nType: Kitchen Fire\nLocation: Floor 2\nSeverity: HIGH\nStatus: Resolved\n\nAll standard emergency protocols followed.\nAll guests evacuated safely.\nNo injuries reported.\n\nCOMPLIANCE STATUS: COMPLIANT';
  }

  Future<String> generateDrillFeedback(int score, String scenario, List<String> mistakes) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return 'DRILL SCORE: 87/100 — GOOD\n\nStrengths:\n✓ Crisis activation under 30 seconds\n✓ All staff responded within 2 minutes\n✓ Evacuation routes followed correctly\n\nImprovements needed:\n⚠ Floor 3 evacuation 45s slower than target\n⚠ Medical kit locations unknown to 2 staff\n\nRecommendations:\n1. Monthly floor warden training\n2. Post medical kit locations on notice boards\n3. Schedule next drill in 30 days';
  }

  Future<List<String>> generateAnalyticsInsights(Map<String, dynamic> stats) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      'This month shows a 23% improvement in average response time.',
      'Medical incidents remain the highest category at 39%.',
      'Recommend increasing first-aid trained staff on night shifts.'
    ];
  }
}
