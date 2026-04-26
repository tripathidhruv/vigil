import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/gemini_service.dart';
import '../auth/auth_provider.dart';

// ── Models ───────────────────────────────────────────────────────────────────

enum AlertSendPhase { idle, translating, ready, sending, sent, error }

class GuestAlertState {
  final String message;
  final String category;
  final String selectedLang;
  final String translatedText;
  final AlertSendPhase phase;
  final String? errorMessage;

  const GuestAlertState({
    this.message = '',
    this.category = 'Safety',
    this.selectedLang = 'English',
    this.translatedText = '',
    this.phase = AlertSendPhase.idle,
    this.errorMessage,
  });

  GuestAlertState copyWith({
    String? message,
    String? category,
    String? selectedLang,
    String? translatedText,
    AlertSendPhase? phase,
    String? errorMessage,
  }) =>
      GuestAlertState(
        message: message ?? this.message,
        category: category ?? this.category,
        selectedLang: selectedLang ?? this.selectedLang,
        translatedText: translatedText ?? this.translatedText,
        phase: phase ?? this.phase,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GuestAlertNotifier extends StateNotifier<GuestAlertState> {
  final GeminiService _geminiService;
  
  final Ref _ref;

  GuestAlertNotifier(this._geminiService, this._ref)
      : super(const GuestAlertState());

  void setMessage(String msg) => state = state.copyWith(message: msg);
  void setCategory(String cat) => state = state.copyWith(category: cat);

  void selectLanguage(String lang) {
    state = state.copyWith(
        selectedLang: lang, translatedText: '', phase: AlertSendPhase.idle);
  }

  Future<void> translate() async {
    if (state.phase == AlertSendPhase.translating) return;
    state = state.copyWith(phase: AlertSendPhase.translating);
    try {
      if (state.selectedLang == 'English' || state.message.isEmpty) {
        state = state.copyWith(
            translatedText: state.message, phase: AlertSendPhase.ready);
        return;
      }
      
      final translation = await _geminiService.translateAlert(
          state.message, state.selectedLang);
          
      state = state.copyWith(
          translatedText: translation,
          phase: AlertSendPhase.ready);
    } catch (e) {
      state = state.copyWith(
        phase: AlertSendPhase.error,
        errorMessage: 'Translation failed: $e',
      );
    }
  }

  Future<void> sendAlert() async {
    state = state.copyWith(phase: AlertSendPhase.sending);
    try {
      // In a real scenario, this would trigger an FCM to guest devices
      // or send SMS via Twilio using the dispatch service.
      // For now, we will simulate the success and write an audit log or a notification.
      
      final authState = _ref.read(authProvider);
      final user = authState.user;

      if (user != null) {
        // Log this action as a system notification
        // Note: For actual guest alerting, we would call an external API (Twilio/SendGrid).
      }
      
      // removed delay
      state = state.copyWith(phase: AlertSendPhase.sent);
    } catch (e) {
      state = state.copyWith(
        phase: AlertSendPhase.error,
        errorMessage: 'Failed to send alert: $e',
      );
    }
  }

  void reset() => state = const GuestAlertState();
}

final guestAlertProvider = StateNotifierProvider<GuestAlertNotifier, GuestAlertState>((ref) {
  final geminiService = ref.watch(geminiProvider);
  return GuestAlertNotifier(geminiService, ref);
});

const List<String> kAlertLanguages = ['English', 'Hindi', 'French', 'Arabic', 'Mandarin', 'Spanish'];
const List<String> kAlertCategories = ['Safety', 'Evacuation', 'Medical', 'Security', 'General'];
