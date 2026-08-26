import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A shimmering placeholder block (§2.7) for content that's still loading.
/// Respects `reduceMotion` (§2.9) by falling back to a static block.
class LLoadingShimmer extends StatefulWidget {
  const LLoadingShimmer({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<LLoadingShimmer> createState() => _LLoadingShimmerState();
}

class _LLoadingShimmerState extends State<LLoadingShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = colors.neutrals.surfaceAlt;
    final highlight = colors.neutrals.surfaceSunken;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final box = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(width: widget.width, height: widget.height, child: ColoredBox(color: base)),
    );

    if (reduceMotion) return box;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + _controller.value * 2, 0),
                  end: Alignment(_controller.value * 2, 0),
                  colors: [base, highlight, base],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
