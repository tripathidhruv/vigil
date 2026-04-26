import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'compliance_provider.dart';

class ComplianceReportScreen extends ConsumerWidget {
  const ComplianceReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(complianceProvider);

    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          AppColors.intelViolet.withOpacity(0.10),
          AppColors.commandBlue.withOpacity(0.07),
          AppColors.statusTeal.withOpacity(0.05),
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
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Compliance Report',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('INC-001 · Kitchen Fire',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.crisisRed)),
                  ]),
                ),
                if (state.isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.safeGreen.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('READY TO EXPORT',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.safeGreen,
                            letterSpacing: 1.5)),
                  ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Generate button
                  if (!state.isGenerating && !state.isComplete)
                    SlideUpReveal(
                      delay: const Duration(milliseconds: 60),
                      child: Column(children: [
                        GlassCard(
                          borderColor:
                              AppColors.intelViolet.withOpacity(0.3),
                          glowColor: AppColors.intelViolet,
                          child: Row(children: [
                            const Icon(Icons.auto_awesome,
                                size: 16,
                                color: AppColors.intelViolet),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Gemini Pro will draft a complete incident report from INC-001 data, ready for regulatory submission.',
                                style: AppTypography.bodySmall
                                    .copyWith(
                                        color: AppColors.intelViolet),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => ref
                              .read(complianceProvider.notifier)
                              .generate(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.intelViolet,
                                  Color(0xFF5A3DAA),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.intelViolet
                                      .withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('GENERATE WITH GEMINI PRO',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.5)),
                            ),
                          ),
                        ),
                      ]),
                    ),

                  // Generating header
                  if (state.isGenerating || state.isComplete) ...[
                    Row(children: [
                      if (state.isGenerating) ...[
                        const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.intelViolet)),
                        const SizedBox(width: 10),
                        Text('Generating report…',
                            style: AppTypography.body.copyWith(
                                color: AppColors.intelViolet)),
                      ] else ...[
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.safeGreen),
                        const SizedBox(width: 10),
                        Text('Report generated',
                            style: AppTypography.body.copyWith(
                                color: AppColors.safeGreen)),
                      ],
                    ]),
                    const SizedBox(height: 16),

                    ...state.sections.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GlassCard(
                          borderColor: section.isLoaded
                              ? AppColors.intelViolet.withOpacity(0.3)
                              : AppColors.borderDefault,
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                            Text(section.title,
                                style: AppTypography.h3.copyWith(
                                    fontSize: 14,
                                    color: section.isLoaded
                                        ? AppColors.intelViolet
                                        : AppColors.textMuted)),
                            const SizedBox(height: 10),
                            if (section.isLoaded)
                              Text(section.content,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.65))
                            else
                              Shimmer.fromColors(
                                baseColor: AppColors.bgElevated,
                                highlightColor: AppColors.borderDefault,
                                child: Column(children: [
                                  for (int i = 0; i < 3; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8),
                                      child: Container(
                                        height: 12,
                                        width: i == 2
                                            ? 180
                                            : double.infinity,
                                        decoration:
                                            BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  4),
                                        ),
                                      ),
                                    ),
                                ]),
                              ),
                          ]),
                        ),
                      );
                    }),

                    // Export
                    if (state.isComplete) ...[
                      const SizedBox(height: 10),
                      GlassCard(
                        borderColor:
                            AppColors.safeGreen.withOpacity(0.35),
                        glowColor: AppColors.safeGreen,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded,
                                  color: AppColors.safeGreen,
                                  size: 20),
                              SizedBox(width: 10),
                              Text('EXPORT AS PDF',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.safeGreen,
                                      letterSpacing: 1.5)),
                            ]),
                      ),
                    ],
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
