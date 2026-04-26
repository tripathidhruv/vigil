import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/animations/typewriter_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'activation_provider.dart';

const _kTypes = [
  ('Fire', Icons.local_fire_department_outlined, AppColors.crisisRed),
  ('Medical', Icons.medical_services_outlined, AppColors.alertOrange),
  ('Security', Icons.security_outlined, AppColors.warningAmber),
  ('Flood', Icons.water_outlined, AppColors.commandBlue),
  ('Power', Icons.power_off_outlined, AppColors.intelViolet),
  ('Earthquake', Icons.layers_outlined, AppColors.alertOrange),
  ('Elevator', Icons.elevator_outlined, AppColors.statusTeal),
  ('Other', Icons.more_horiz, AppColors.textMuted),
];

class CrisisActivationScreen extends ConsumerStatefulWidget {
  const CrisisActivationScreen({super.key});
  @override
  ConsumerState<CrisisActivationScreen> createState() =>
      _CrisisActivationScreenState();
}

class _CrisisActivationScreenState
    extends ConsumerState<CrisisActivationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdCtrl;
  bool _isHolding = false;
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _holdCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _holdCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _isHolding) _activate();
    });
  }

  @override
  void dispose() {
    _holdCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    HapticFeedback.heavyImpact();
    final notifier = ref.read(activationProvider.notifier);
    notifier.setLocation(_locationCtrl.text.trim());
    notifier.setDescription(_descCtrl.text.trim());
    await notifier.analyzeAndActivate();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activationProvider);

    // On confirmation navigate to command centre
    ref.listen(activationProvider, (_, next) {
      if (next.phase == ActivationPhase.confirmed) {
        if (mounted) context.go('/crisis-command/${next.incidentId}');
      }
    });

    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          AppColors.crisisRed.withOpacity(0.14),
          AppColors.alertOrange.withOpacity(0.07),
          AppColors.intelViolet.withOpacity(0.05),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => context.pop(),
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
                  const Text('Report Incident',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 18,
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      )),
                ]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: state.phase == ActivationPhase.confirmed
                      ? _buildResult(state)
                      : _buildForm(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ActivationState state) {
    final sel = state.incidentType;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Type selector
      SlideUpReveal(
        delay: const Duration(milliseconds: 60),
        child: Text('Incident Type', style: AppTypography.h3),
      ),
      const SizedBox(height: 12),
      SlideUpReveal(
        delay: const Duration(milliseconds: 100),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          for (final t in _kTypes)
            GestureDetector(
              onTap: () =>
                  ref.read(activationProvider.notifier).setType(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel == t.$1
                      ? t.$3.withOpacity(0.15)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel == t.$1
                        ? t.$3.withOpacity(0.6)
                        : AppColors.borderDefault,
                    width: sel == t.$1 ? 1.5 : 1.0,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(t.$2, size: 16, color: sel == t.$1 ? t.$3 : AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(t.$1,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel == t.$1 ? t.$3 : AppColors.textSecondary)),
                ]),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 24),

      // Location
      SlideUpReveal(
        delay: const Duration(milliseconds: 140),
        child: Text('Location', style: AppTypography.h3),
      ),
      const SizedBox(height: 10),
      SlideUpReveal(
        delay: const Duration(milliseconds: 170),
        child: TextField(
          controller: _locationCtrl,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Floor 2 · Main Kitchen',
            prefixIcon: Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.textMuted),
          ),
        ),
      ),
      const SizedBox(height: 18),

      // Description
      SlideUpReveal(
        delay: const Duration(milliseconds: 200),
        child: Text('Description', style: AppTypography.h3),
      ),
      const SizedBox(height: 10),
      SlideUpReveal(
        delay: const Duration(milliseconds: 230),
        child: TextField(
          controller: _descCtrl,
          maxLines: 3,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Briefly describe what is happening…',
            alignLabelWithHint: true,
          ),
        ),
      ),
      const SizedBox(height: 36),

      // Hold-to-activate
      SlideUpReveal(
        delay: const Duration(milliseconds: 280),
        child: Center(
          child: Column(children: [
            GestureDetector(
              onLongPressStart: (_) {
                if (state.incidentType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select an incident type first')));
                  return;
                }
                setState(() => _isHolding = true);
                HapticFeedback.mediumImpact();
                _holdCtrl.forward();
              },
              onLongPressEnd: (_) {
                setState(() => _isHolding = false);
                _holdCtrl.reverse();
              },
              onLongPressCancel: () {
                setState(() => _isHolding = false);
                _holdCtrl.reverse();
              },
              child: AnimatedBuilder(
                animation: _holdCtrl,
                builder: (_, __) => SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: _holdCtrl.value,
                        strokeWidth: 5,
                        backgroundColor: AppColors.crisisRedDim,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.crisisRed),
                      ),
                    ),
                    Container(
                      width: 158,
                      height: 158,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isHolding
                            ? AppColors.crisisRedDim
                            : AppColors.bgCard,
                        border: Border.all(
                          color: _isHolding
                              ? AppColors.crisisRed
                              : AppColors.borderDefault,
                          width: 2,
                        ),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isHolding
                                  ? Icons.warning_rounded
                                  : Icons.warning_outlined,
                              size: 48,
                              color: _isHolding
                                  ? AppColors.crisisRed
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isHolding ? 'ACTIVATING…' : 'HOLD TO\nACTIVATE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _isHolding
                                    ? AppColors.crisisRed
                                    : AppColors.textMuted,
                                letterSpacing: 1.5,
                                height: 1.35,
                              ),
                            ),
                          ]),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.phase == ActivationPhase.analyzing)
              const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.intelViolet)),
                    SizedBox(width: 10),
                    Text('Gemini is analysing…',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.intelViolet)),
                  ])
            else
              Text('Hold for 2.5 seconds to activate crisis protocol',
                  style: AppTypography.bodySmall),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildResult(ActivationState state) {
    return Column(children: [
      const SizedBox(height: 20),
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.crisisRedDim,
            border: Border.all(color: AppColors.crisisRed, width: 1.5)),
        child: const Icon(Icons.warning_rounded,
            size: 38, color: AppColors.crisisRed),
      ),
      const SizedBox(height: 20),
      Text('Crisis Activated', style: AppTypography.h1),
      const SizedBox(height: 6),
      Text('INC-${state.incidentId}',
          style: AppTypography.mono.copyWith(color: AppColors.crisisRed)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.crisisRedDim,
            borderRadius: BorderRadius.circular(6)),
        child: Text('${state.severity} SEVERITY',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.crisisRed,
                letterSpacing: 1.5)),
      ),
      const SizedBox(height: 28),
      GlassCard(
        borderColor: AppColors.intelViolet.withOpacity(0.35),
        glowColor: AppColors.intelViolet,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, size: 16, color: AppColors.intelViolet),
            const SizedBox(width: 8),
            Text('AI RESPONSE PLAYBOOK',
                style: AppTypography.label
                    .copyWith(color: AppColors.intelViolet)),
          ]),
          const SizedBox(height: 14),
          ...state.playbook.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                        color: AppColors.intelViolet.withOpacity(0.15),
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text('${step.step}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.intelViolet)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TypewriterText(
                            text: step.action,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.4),
                            charDelay: const Duration(milliseconds: 18),
                            startDelay: Duration(milliseconds: step.step * 400),
                          ),
                          const SizedBox(height: 2),
                          Text('→ ${step.owner}',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.intelViolet)),
                        ]),
                  ),
                ]),
              )),
        ]),
      ),
      const SizedBox(height: 20),
      const Text('Navigating to Command Centre…',
          style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.textMuted)),
    ]);
  }
}
