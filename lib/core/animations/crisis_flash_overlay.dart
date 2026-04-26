import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// App-root red flash overlay triggered on crisis activation.
/// Usage: wrap MaterialApp child in a Stack with this widget,
/// then call [CrisisFlashOverlayState.flash()] through a GlobalKey.
class CrisisFlashOverlay extends StatefulWidget {
  final Widget child;

  const CrisisFlashOverlay({super.key, required this.child});

  @override
  State<CrisisFlashOverlay> createState() => CrisisFlashOverlayState();
}

class CrisisFlashOverlayState extends State<CrisisFlashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 60),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger the red flash effect.
  void flash() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _opacityAnim,
          builder: (context, _) {
            if (_opacityAnim.value == 0) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: AppColors.crisisRed.withOpacity(_opacityAnim.value),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
