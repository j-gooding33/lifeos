import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A film/book poster tile (§2.7). Renders the real artwork when given an
/// [imageProvider]; otherwise an honest placeholder icon — never
/// invented/mock artwork (CLAUDE.md rule 1).
class LPosterTile extends StatelessWidget {
  const LPosterTile({
    required this.width,
    this.imageProvider,
    this.aspectRatio = 2 / 3,
    this.onTap,
    super.key,
  });

  final double width;
  final ImageProvider? imageProvider;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: imageProvider != null
              ? Image(image: imageProvider!, fit: BoxFit.cover)
              : ColoredBox(
                  color: colors.neutrals.surfaceAlt,
                  child: Icon(Icons.image_not_supported_outlined, color: colors.neutrals.ink3),
                ),
        ),
      ),
    );

    if (onTap == null) return tile;
    return GestureDetector(onTap: onTap, child: tile);
  }
}
