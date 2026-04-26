import 'package:flutter/material.dart';

/// Animates an integer from [start] to [end] with easing.
/// Useful for hero stat numbers (incident count, response time, etc.).
class CountUpNumber extends StatefulWidget {
  final int start;
  final int end;
  final Duration duration;
  final TextStyle? style;
  final String suffix;
  final String prefix;

  const CountUpNumber({
    super.key,
    this.start = 0,
    required this.end,
    this.duration = const Duration(milliseconds: 1400),
    this.style,
    this.suffix = '',
    this.prefix = '',
  });

  @override
  State<CountUpNumber> createState() => _CountUpNumberState();
}

class _CountUpNumberState extends State<CountUpNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: widget.start.toDouble(),
      end: widget.end.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUpNumber old) {
    super.didUpdateWidget(old);
    if (old.end != widget.end) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.end.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Text('${widget.prefix}${widget.end}${widget.suffix}',
          style: widget.style);
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          '${widget.prefix}${_animation.value.round()}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
