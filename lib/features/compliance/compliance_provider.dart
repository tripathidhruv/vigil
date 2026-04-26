import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class ReportSection {
  final String title;
  final String content;
  final bool isLoaded;

  const ReportSection({
    required this.title,
    this.content = '',
    this.isLoaded = false,
  });

  ReportSection copyWith({String? content, bool? isLoaded}) => ReportSection(
        title: title,
        content: content ?? this.content,
        isLoaded: isLoaded ?? this.isLoaded,
      );
}

class ComplianceState {
  final bool isGenerating;
  final bool isComplete;
  final List<ReportSection> sections;

  const ComplianceState({
    this.isGenerating = false,
    this.isComplete = false,
    this.sections = const [],
  });

  ComplianceState copyWith({
    bool? isGenerating,
    bool? isComplete,
    List<ReportSection>? sections,
  }) =>
      ComplianceState(
        isGenerating: isGenerating ?? this.isGenerating,
        isComplete: isComplete ?? this.isComplete,
        sections: sections ?? this.sections,
      );
}

const List<ReportSection> _kEmptySections = [
  ReportSection(title: '1. Incident Overview'),
  ReportSection(title: '2. Timeline & Chronology'),
  ReportSection(title: '3. Response Actions'),
  ReportSection(title: '4. Guest Impact Assessment'),
  ReportSection(title: '5. Regulatory Notifications'),
];

const _kSectionContent = [
  'Kitchen fire outbreak detected at 18:01 hrs in Main Kitchen, Floor 2. '
      'Hotel automatic suppression system activated within 42 seconds. '
      'Severity classified as CRITICAL by AI triage system. '
      'Hotel Incident ID: INC-001. No guest casualties reported.',
  '18:01 — Fire suppression system triggered.\n'
      '18:02 — Security Chief Sarah Chen deployed to Floor 2.\n'
      '18:03 — Floor 2 guest evacuation commenced.\n'
      '18:06 — Mumbai Fire Brigade arrived on site.\n'
      '18:24 — Fire fully extinguished. All-clear declared at 18:31.',
  'Immediate evacuation of Floor 2 (14 guests). '
      'Engineering team isolated gas supply within 4 minutes. '
      'Guest welfare check conducted by Front Desk. '
      'Medical team on standby — no injuries recorded. '
      'CCTV footage preserved for investigation.',
  '14 guests evacuated from Floor 2 rooms. '
      'F&B operations suspended for 3 hours. '
      'Estimated property damage: ₹2.4L (kitchen equipment). '
      'Zero guest injuries. 2 guests relocated to alternative rooms. '
      'Guests offered complimentary dining as service recovery.',
  'Maharashtra Fire Department: Incident report submitted per Rule 14(3).\n'
      'Insurance carrier notified within 2 hours as per policy clause.\n'
      'FSSAI kitchen inspection scheduled within 72 hours.\n'
      'Hotel Association of India notification filed.',
];

// ── Notifier ──────────────────────────────────────────────────────────────────

class ComplianceNotifier extends StateNotifier<ComplianceState> {
  ComplianceNotifier() : super(const ComplianceState(sections: _kEmptySections));

  Future<void> generate() async {
    state = state.copyWith(isGenerating: true, sections: _kEmptySections);
    for (int i = 0; i < _kEmptySections.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      final updated = List<ReportSection>.from(state.sections);
      updated[i] = updated[i].copyWith(
        content: _kSectionContent[i],
        isLoaded: true,
      );
      state = state.copyWith(sections: updated);
    }
    state = state.copyWith(isGenerating: false, isComplete: true);
  }
}

final complianceProvider = StateNotifierProvider<ComplianceNotifier, ComplianceState>(
    (ref) => ComplianceNotifier());
