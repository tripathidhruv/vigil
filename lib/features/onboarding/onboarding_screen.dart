import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class _Page {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<Color> blobs;
  const _Page(this.icon, this.color, this.title, this.subtitle, this.blobs);
}

const _pages = [
  _Page(Icons.warning_amber_rounded, AppColors.crisisRed,
      'Detect Threats\nInstantly',
      'AI classification surfaces critical crises in under 2 seconds. No threat goes unnoticed.',
      [AppColors.crisisRed, AppColors.intelViolet, AppColors.commandBlue]),
  _Page(Icons.groups_rounded, AppColors.commandBlue,
      'Coordinate\nYour Team',
      'Real-time war room keeps every department in sync — assign, track and resolve live.',
      [AppColors.commandBlue, AppColors.statusTeal, AppColors.intelViolet]),
  _Page(Icons.map_outlined, AppColors.statusTeal,
      'Command the\nFloor',
      'Live floor maps show staff positions, IoT sensor alerts, and evacuation routes.',
      [AppColors.statusTeal, AppColors.commandBlue, AppColors.safeGreen]),
  _Page(Icons.verified_outlined, AppColors.safeGreen,
      'Stay Compliant\nAutomatically',
      'Every incident auto-generates a compliance report ready for regulatory submission.',
      [AppColors.safeGreen, AppColors.statusTeal, AppColors.intelViolet]),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic);
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_page];
    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          p.blobs[0].withOpacity(0.10),
          p.blobs[1].withOpacity(0.07),
          p.blobs[2].withOpacity(0.05),
        ],
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: TextButton(
                    onPressed: () => context.go('/auth'),
                    child: Text('Skip',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final pg = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideUpReveal(
                            delay: const Duration(milliseconds: 60),
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  pg.color.withOpacity(0.16),
                                  Colors.transparent
                                ]),
                                border: Border.all(
                                    color: pg.color.withOpacity(0.38),
                                    width: 1.5),
                              ),
                              child: Icon(pg.icon, size: 62, color: pg.color),
                            ),
                          ),
                          const SizedBox(height: 44),
                          SlideUpReveal(
                            delay: const Duration(milliseconds: 160),
                            child: Text(pg.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                )),
                          ),
                          const SizedBox(height: 18),
                          SlideUpReveal(
                            delay: const Duration(milliseconds: 260),
                            child: Text(pg.subtitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.body
                                    .copyWith(fontSize: 16, height: 1.65)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _ctrl,
                      count: _pages.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 10,
                        dotColor: AppColors.borderDefault,
                        activeDotColor: p.color,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _next,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        borderColor: p.color.withOpacity(0.45),
                        glowColor: p.color,
                        child: Center(
                          child: Text(
                            _page == _pages.length - 1
                                ? 'GET STARTED →'
                                : 'NEXT →',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.color,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
