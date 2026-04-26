import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The VIGIL glassmorphic card — frosted glass surface with optional glow border.
/// Wrap content in this for all bento-grid tiles and modal panels.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color? glowColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.blur = 12.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 16.0,
    this.glowColor,
    this.width,
    this.height,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? AppColors.glassBorder;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? AppColors.glassSurface : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: effectiveBorder, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );

    // Optional outer glow via BoxShadow
    if (glowColor != null) {
      card = Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: glowColor!.withOpacity(0.20),
              blurRadius: 32,
              spreadRadius: -4,
            ),
          ],
        ),
        child: card,
      );
    } else {
      card = Padding(padding: margin ?? EdgeInsets.zero, child: card);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}
