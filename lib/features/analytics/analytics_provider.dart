import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  await Future.delayed(const Duration(milliseconds: 800));
  return const AnalyticsData(
    incidentsByType: [
      BarStat('Fire', 8, 'red'),
      BarStat('Medical', 14, 'amber'),
      BarStat('Security', 6, 'blue'),
      BarStat('Flood', 3, 'teal'),
      BarStat('Other', 5, 'orange'),
    ],
    responseTimeTrend: [
      LineStat(0, 9.2),
      LineStat(1, 7.8),
      LineStat(2, 8.5),
      LineStat(3, 6.2),
      LineStat(4, 5.4),
      LineStat(5, 4.1),
      LineStat(6, 3.8),
    ],
    totalIncidents: 36,
    avgResponseMin: 4,
    resolutionRate: 94.4,
    insights: [
      'Kitchen fire incidents increased 40% this month — schedule a fire safety drill.',
      'Medical emergencies peak on weekends (Fri–Sun). Consider adding a part-time medic.',
      'Average response time improved from 9.2 min to 3.8 min over 7 weeks — great progress.',
      'Security incidents cluster between 22:00 and 02:00. Adjust night patrol schedule.',
      'Resolution rate of 94.4% is above industry benchmark (87%). Keep it up.',
    ],
  );
});
