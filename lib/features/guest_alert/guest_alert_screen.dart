import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'alert_provider.dart';

class GuestAlertScreen extends ConsumerWidget {
  const GuestAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guestAlertProvider);
    final notifier = ref.read(guestAlertProvider.notifier);

    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          AppColors.commandBlue.withOpacity(0.10),
          AppColors.statusTeal.withOpacity(0.07),
          AppColors.intelViolet.withOpacity(0.05),
        ],
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go('/crisis-command'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderDefault)),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Guest Alert',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ]),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: state.phase == AlertSendPhase.sent
                    ? _buildSuccess(context, ref)
                    : _buildComposer(context, state, notifier),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildComposer(
    BuildContext context,
    GuestAlertState state,
    GuestAlertNotifier notifier,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Category
      SlideUpReveal(
        delay: const Duration(milliseconds: 60),
        child: Text('Category', style: AppTypography.h3),
      ),
      const SizedBox(height: 10),
      SlideUpReveal(
        delay: const Duration(milliseconds: 90),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final cat in kAlertCategories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => notifier.setCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: state.category == cat
                          ? AppColors.commandBlue.withOpacity(0.14)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: state.category == cat
                              ? AppColors.commandBlue
                              : AppColors.borderDefault,
                          width:
                              state.category == cat ? 1.5 : 1.0),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: state.category == cat
                                ? AppColors.commandBlue
                                : AppColors.textSecondary)),
                  ),
                ),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 20),

      // Message
      SlideUpReveal(
        delay: const Duration(milliseconds: 130),
        child: Text('Message', style: AppTypography.h3),
      ),
      const SizedBox(height: 10),
      SlideUpReveal(
        delay: const Duration(milliseconds: 160),
        child: TextField(
          maxLines: 4,
          onChanged: notifier.setMessage,
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText:
                'Please remain calm. Hotel management has the situation under control. Please remain in your room.',
            alignLabelWithHint: true,
          ),
        ),
      ),
      const SizedBox(height: 20),

      // Language
      SlideUpReveal(
        delay: const Duration(milliseconds: 200),
        child: Text('Translate to', style: AppTypography.h3),
      ),
      const SizedBox(height: 10),
      SlideUpReveal(
        delay: const Duration(milliseconds: 230),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final lang in kAlertLanguages)
            GestureDetector(
              onTap: () => notifier.selectLanguage(lang),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: state.selectedLang == lang
                      ? AppColors.statusTeal.withOpacity(0.14)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: state.selectedLang == lang
                          ? AppColors.statusTeal
                          : AppColors.borderDefault,
                      width: state.selectedLang == lang ? 1.5 : 1.0),
                ),
                child: Text(lang,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: state.selectedLang == lang
                            ? AppColors.statusTeal
                            : AppColors.textSecondary)),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 20),

      // Translation Preview
      if (state.phase == AlertSendPhase.translating)
        GlassCard(
          child: Row(children: [
            const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.intelViolet),
            ),
            const SizedBox(width: 14),
            Text('Translating via Gemini…',
                style: AppTypography.body
                    .copyWith(color: AppColors.intelViolet)),
          ]),
        ),
      if (state.phase == AlertSendPhase.ready ||
          state.phase == AlertSendPhase.sending) ...[
        GlassCard(
          borderColor: AppColors.statusTeal.withOpacity(0.35),
          glowColor: AppColors.statusTeal,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              const Icon(Icons.translate,
                  size: 16, color: AppColors.statusTeal),
              const SizedBox(width: 8),
              Text('TRANSLATED · ${state.selectedLang.toUpperCase()}',
                  style: AppTypography.label
                      .copyWith(color: AppColors.statusTeal)),
            ]),
            const SizedBox(height: 10),
            Text(state.translatedText,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5)),
          ]),
        ),
      ],
      const SizedBox(height: 28),

      // Buttons
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: state.phase == AlertSendPhase.translating
                ? null
                : notifier.translate,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderColor: AppColors.intelViolet.withOpacity(0.4),
              child: Center(
                child: Text('TRANSLATE',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.intelViolet,
                        letterSpacing: 1.5)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: state.phase == AlertSendPhase.ready
                ? notifier.sendAlert
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: state.phase == AlertSendPhase.ready
                    ? LinearGradient(colors: [
                        AppColors.commandBlue,
                        const Color(0xFF1E5BAA),
                      ])
                    : null,
                color: state.phase == AlertSendPhase.ready
                    ? null
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: state.phase != AlertSendPhase.ready
                    ? Border.all(color: AppColors.borderDefault)
                    : null,
              ),
              child: Center(
                child: state.phase == AlertSendPhase.sending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white))
                    : Text('SEND ALERT',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: state.phase == AlertSendPhase.ready
                                ? Colors.white
                                : AppColors.textMuted,
                            letterSpacing: 1.5)),
              ),
            ),
          ),
        ),
      ]),
    ]);
  }

  Widget _buildSuccess(BuildContext context, WidgetRef ref) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      const SizedBox(height: 60),
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.safeGreen.withOpacity(0.12),
            border:
                Border.all(color: AppColors.safeGreen, width: 1.5)),
        child: const Icon(Icons.check_rounded,
            size: 40, color: AppColors.safeGreen),
      ),
      const SizedBox(height: 22),
      const Text('Alert Sent!',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Text('Your alert was broadcast to all guests in the selected scope.',
          textAlign: TextAlign.center,
          style: AppTypography.body),
      const SizedBox(height: 36),
      GestureDetector(
        onTap: () {
          ref.read(guestAlertProvider.notifier).reset();
          context.go('/crisis-command');
        },
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderColor: AppColors.commandBlue.withOpacity(0.4),
          child: const Center(
            child: Text('BACK TO COMMAND',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.commandBlue,
                    letterSpacing: 1.5)),
          ),
        ),
      ),
    ]);
  }
}
