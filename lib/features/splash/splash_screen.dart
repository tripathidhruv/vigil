import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/animations/typewriter_text.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _showTagline = false;
  bool _showStatus = false;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.72, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _opacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showTagline = true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showStatus = true);
    });
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          AppColors.crisisRed.withOpacity(0.12),
          AppColors.intelViolet.withOpacity(0.08),
          AppColors.commandBlue.withOpacity(0.06),
        ],
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Logo mark ──────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (ctx, child) => Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(scale: _scale.value, child: child),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.crisisRed.withOpacity(0.18),
                          Colors.transparent,
                        ]),
                        border: Border.all(
                            color: AppColors.crisisRed.withOpacity(0.55),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          size: 52, color: AppColors.crisisRed),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'VIGIL',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 58,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── Typewriter tagline ─────────────────────────────────────────
              SlideUpReveal(
                visible: _showTagline,
                delay: const Duration(milliseconds: 80),
                child: TypewriterText(
                  text: 'CRISIS COMMAND & COORDINATION',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 3.8,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Status + progress ──────────────────────────────────────────
              AnimatedOpacity(
                opacity: _showStatus ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 52),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.statusTeal),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ALL SYSTEMS OPERATIONAL',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.statusTeal,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2200),
                          curve: Curves.easeInOut,
                          builder: (ctx, v, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: v,
                              minHeight: 2,
                              backgroundColor: AppColors.borderDefault,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.crisisRed),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
