import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firebase_service.dart';
import '../../services/gemini_service.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class BarStat {
  final String label;
  final double value;
  final String colorKey; // 'red','amber','blue','teal','orange'
  const BarStat(this.label, this.value, this.colorKey);
}

class LineStat {
  final double x;
  final double y;
  const LineStat(this.x, this.y);
}

class AnalyticsData {
  final List<BarStat> incidentsByType;
  final List<LineStat> responseTimeTrend;
  final int totalIncidents;
  final int avgResponseMin;
  final double resolutionRate;
  final List<String> insights;

  const AnalyticsData({
    required this.incidentsByType,
    required this.responseTimeTrend,
    required this.totalIncidents,
    required this.avgResponseMin,
    required this.resolutionRate,
    required this.insights,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final fbService = ref.watch(firebaseProvider);
  final geminiService = ref.watch(geminiProvider);

  final allDocs = await fbService.getAllIncidents();
  
  if (allDocs.isEmpty) {
    return const AnalyticsData(
      incidentsByType: [],
      responseTimeTrend: [],
      totalIncidents: 0,
      avgResponseMin: 0,
      resolutionRate: 0.0,
      insights: ['No data available yet.'],
    );
  }

  Map<String, int> typeCount = {
    'Fire': 0,
    'Medical': 0,
    'Security': 0,
    'Flood': 0,
    'Other': 0,
  };

  int resolvedCount = 0;

  for (var inc in allDocs) {
    if (typeCount.containsKey(inc.type)) {
      typeCount[inc.type] = typeCount[inc.type]! + 1;
    } else {
      typeCount['Other'] = typeCount['Other']! + 1;
    }
    if (inc.status == 'resolved') {
      resolvedCount++;
    }
  }

  final incidentsByType = [
    BarStat('Fire', typeCount['Fire']!.toDouble(), 'red'),
    BarStat('Medical', typeCount['Medical']!.toDouble(), 'amber'),
    BarStat('Security', typeCount['Security']!.toDouble(), 'blue'),
    BarStat('Flood', typeCount['Flood']!.toDouble(), 'teal'),
    BarStat('Other', typeCount['Other']!.toDouble(), 'orange'),
  ];

  final resolutionRate = (resolvedCount / allDocs.length) * 100;
  
  // Mocking trend data for now since we don't have historical resolution times
  // In a real app, this would be computed by querying incidents over the past 7 days.
  final responseTimeTrend = const [
    LineStat(0, 9.2),
    LineStat(1, 7.8),
    LineStat(2, 8.5),
    LineStat(3, 6.2),
    LineStat(4, 5.4),
    LineStat(5, 4.1),
    LineStat(6, 3.8),
  ];
  
  final statsData = {
    'totalIncidents': allDocs.length,
    'resolvedCount': resolvedCount,
    'typeBreakdown': typeCount,
    'resolutionRate': resolutionRate,
  };

  final insights = await geminiService.generateAnalyticsInsights(statsData);

  return AnalyticsData(
    incidentsByType: incidentsByType,
    responseTimeTrend: responseTimeTrend,
    totalIncidents: allDocs.length,
    avgResponseMin: 4, // Default assuming 4 mins avg
    resolutionRate: resolutionRate,
    insights: insights.isEmpty ? ['No insights generated'] : insights,
  );
});
