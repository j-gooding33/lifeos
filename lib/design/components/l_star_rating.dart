import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';

/// A star rating (§2.7-adjacent, M8 Part 44) — read-only display or an
/// interactive picker (tap the left/right half of a star for a half-step).
/// Supports up to 6 stars: when [maxRating] is 6, the 6th star renders in a
/// distinct colour (M8 Part 12 — "exceptional personal favourite", never
/// just "6 out of 5"), everything else shares one visual language.
class LStarRating extends StatelessWidget {
  const LStarRating({
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.onChanged,
    super.key,
  });

  /// 0–[maxRating], in 0.5 steps. Null renders as unrated (all empty).
  final double? rating;
  final int maxRating;
  final double size;

  /// Null makes this a read-only display.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = rating ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < maxRating; i++) _buildStar(context, colors, i, value),
      ],
    );
  }

  Widget _buildStar(BuildContext context, LifeColors colors, int index, double value) {
    final isSixth = maxRating == 6 && index == 5;
    final fillColor = isSixth ? colors.semantic('warning').base : colors.accent.base;
    final fraction = (value - index).clamp(0.0, 1.0);

    final star = SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Icon(isSixth ? Icons.auto_awesome_outlined : Icons.star_border, size: size, color: colors.neutrals.ink3),
          if (fraction > 0)
            ClipRect(
              clipper: _FractionClipper(fraction),
              child: Icon(isSixth ? Icons.auto_awesome : Icons.star, size: size, color: fillColor),
            ),
        ],
      ),
    );

    if (onChanged == null) return star;
    return GestureDetector(
      onTapUp: (details) {
        final tappedRightHalf = details.localPosition.dx > size / 2;
        onChanged!(index + (tappedRightHalf ? 1.0 : 0.5));
      },
      child: star,
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(covariant _FractionClipper oldClipper) => oldClipper.fraction != fraction;
}
