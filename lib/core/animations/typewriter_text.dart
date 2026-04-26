import 'package:flutter/material.dart';

/// Renders text character-by-character at a typewriter pace.
/// Used in Gemini AI response panels and mission briefings.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;
  final Duration startDelay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 28),
    this.startDelay = Duration.zero,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayed = '';
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.startDelay, _start);
  }

  @override
  void didUpdateWidget(TypewriterText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _displayed = '';
      _started = false;
      Future.delayed(widget.startDelay, _start);
    }
  }

  void _start() {
    if (!mounted || _started) return;
    _started = true;
    _type(0);
  }

  void _type(int index) {
    if (!mounted || index >= widget.text.length) {
      widget.onComplete?.call();
      return;
    }
    setState(() => _displayed = widget.text.substring(0, index + 1));
    Future.delayed(widget.charDelay, () => _type(index + 1));
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Text(widget.text, style: widget.style);
    }
    return Text(_displayed, style: widget.style);
  }
}
