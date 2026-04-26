import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ───────────────────────────────────────────────────────────────────

enum AlertSendPhase { idle, translating, ready, sending, sent }

class GuestAlertState {
  final String message;
  final String category;
  final String selectedLang;
  final String translatedText;
  final AlertSendPhase phase;

  const GuestAlertState({
    this.message = '',
    this.category = 'Safety',
    this.selectedLang = 'English',
    this.translatedText = '',
    this.phase = AlertSendPhase.idle,
  });

  GuestAlertState copyWith({
    String? message,
    String? category,
    String? selectedLang,
    String? translatedText,
    AlertSendPhase? phase,
  }) =>
      GuestAlertState(
        message: message ?? this.message,
        category: category ?? this.category,
        selectedLang: selectedLang ?? this.selectedLang,
        translatedText: translatedText ?? this.translatedText,
        phase: phase ?? this.phase,
      );
}

// ── Mock translations ─────────────────────────────────────────────────────────

const Map<String, String> _kTranslations = {
  'Hindi': 'कृपया शांत रहें। होटल प्रबंधन स्थिति को नियंत्रण में ले रहा है। कृपया अपने कमरे में रहें।',
  'French': 'Veuillez rester calme. La direction de l\'hôtel maîtrise la situation. Restez dans votre chambre.',
  'Arabic': 'يرجى البقاء هادئًا. تتولى إدارة الفندق السيطرة على الوضع. يرجى البقاء في غرفتك.',
  'Mandarin': '请保持冷静。酒店管理层正在控制局面。请留在您的房间。',
  'Spanish': 'Por favor, mantenga la calma. La dirección del hotel está controlando la situación.',
};

// ── Notifier ──────────────────────────────────────────────────────────────────

class GuestAlertNotifier extends StateNotifier<GuestAlertState> {
  GuestAlertNotifier() : super(const GuestAlertState());

  void setMessage(String msg) => state = state.copyWith(message: msg);
  void setCategory(String cat) => state = state.copyWith(category: cat);

  void selectLanguage(String lang) {
    state = state.copyWith(selectedLang: lang, translatedText: '', phase: AlertSendPhase.idle);
  }

  Future<void> translate() async {
    state = state.copyWith(phase: AlertSendPhase.translating);
    await Future.delayed(const Duration(milliseconds: 1400));
    final translated = state.selectedLang == 'English'
        ? state.message
        : _kTranslations[state.selectedLang] ??
            'Please remain calm. Hotel management has the situation under control.';
    state = state.copyWith(translatedText: translated, phase: AlertSendPhase.ready);
  }

  Future<void> sendAlert() async {
    state = state.copyWith(phase: AlertSendPhase.sending);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(phase: AlertSendPhase.sent);
  }

  void reset() => state = const GuestAlertState();
}

final guestAlertProvider = StateNotifierProvider<GuestAlertNotifier, GuestAlertState>(
    (ref) => GuestAlertNotifier());

const List<String> kAlertLanguages = ['English', 'Hindi', 'French', 'Arabic', 'Mandarin', 'Spanish'];
const List<String> kAlertCategories = ['Safety', 'Evacuation', 'Medical', 'Security', 'General'];
