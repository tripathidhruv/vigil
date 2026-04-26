import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/gemini_service.dart';
import '../../services/firebase_service.dart';

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
  final String? errorMessage;

  const ComplianceState({
    this.isGenerating = false,
    this.isComplete = false,
    this.sections = const [],
    this.errorMessage,
  });

  ComplianceState copyWith({
    bool? isGenerating,
    bool? isComplete,
    List<ReportSection>? sections,
    String? errorMessage,
  }) =>
      ComplianceState(
        isGenerating: isGenerating ?? this.isGenerating,
        isComplete: isComplete ?? this.isComplete,
        sections: sections ?? this.sections,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

const List<ReportSection> _kEmptySections = [
  ReportSection(title: '1. Executive Summary'),
  ReportSection(title: '2. Timeline of Events'),
  ReportSection(title: '3. Response Actions Taken'),
  ReportSection(title: '4. Regulatory Compliance Assessment'),
  ReportSection(title: '5. Recommendations'),
];

// ── Notifier ──────────────────────────────────────────────────────────────────

class ComplianceNotifier extends StateNotifier<ComplianceState> {
  final GeminiService _geminiService;
  final FirebaseService _firebaseService;

  ComplianceNotifier(this._geminiService, this._firebaseService)
      : super(const ComplianceState(sections: _kEmptySections));

  Future<void> generate(String incidentId) async {
    if (state.isGenerating) return;
    state = state.copyWith(isGenerating: true, sections: _kEmptySections, errorMessage: null);
    
    try {
      // 1. Fetch incident details
      final incidentStream = _firebaseService.streamIncident(incidentId);
      final incident = await incidentStream.first;
      
      if (incident == null) {
        state = state.copyWith(
          isGenerating: false,
          errorMessage: 'Incident not found',
        );
        return;
      }

      // We need a resolved time. Let's assume it was resolved now if active, or just use now
      final resolvedTime = DateTime.now();

      // 2. Generate report text via Gemini
      final reportText = await _geminiService.generateComplianceReport(
        incidentType: incident.type,
        severity: 'SEV-${incident.severity}',
        startTime: incident.timestamp,
        resolvedTime: resolvedTime,
        location: incident.location,
        responseActions: incident.notes.isNotEmpty ? incident.notes : 'Standard response playbook executed.',
      );

      // 3. Parse Gemini output into sections
      // The prompt asks for 5 sections. We can try to split by numbered list
      final parsedSections = _parseSections(reportText);

      // 4. Update UI progressively
      for (int i = 0; i < _kEmptySections.length; i++) {
        // removed delay
        if (!mounted) return;
        final updated = List<ReportSection>.from(state.sections);
        
        final content = i < parsedSections.length 
            ? parsedSections[i] 
            : 'Section generation incomplete.';
            
        updated[i] = updated[i].copyWith(
          content: content,
          isLoaded: true,
        );
        state = state.copyWith(sections: updated);
      }
      state = state.copyWith(isGenerating: false, isComplete: true);
      
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'Report generation failed: $e',
      );
    }
  }
  
  List<String> _parseSections(String text) {
    // Basic regex split by "1.", "2.", etc.
    final List<String> result = [];
    final pattern = RegExp(r'\d\.\s+[^\n]+');
    final matches = pattern.allMatches(text).toList();
    
    if (matches.isEmpty) {
      return [text]; // Fallback
    }

    for (int i = 0; i < matches.length; i++) {
      final start = matches[i].end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : text.length;
      result.add(text.substring(start, end).trim());
    }
    
    return result;
  }
  
  void reset() => state = const ComplianceState(sections: _kEmptySections);
}

final complianceProvider = StateNotifierProvider<ComplianceNotifier, ComplianceState>((ref) {
  final geminiService = ref.watch(geminiProvider);
  final fbService = ref.watch(firebaseProvider);
  return ComplianceNotifier(geminiService, fbService);
});
