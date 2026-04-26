import 'package:flutter/material.dart';

/// Slides a child widget upward and fades it in from an initial offset.
/// Trigger by changing [visible] from false to true.
class SlideUpReveal extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Duration duration;
  final Duration delay;
  final double offsetY;

  const SlideUpReveal({
    super.key,
    required this.child,
    this.visible = true,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offsetY = 32.0,
  });

  @override
  State<SlideUpReveal> createState() => _SlideUpRevealState();
}

class _SlideUpRevealState extends State<SlideUpReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _slideAnim = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.visible) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(SlideUpReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else if (!widget.visible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(position: _slideAnim, child: widget.child),
    );
  }
}
