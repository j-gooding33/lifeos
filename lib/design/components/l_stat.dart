import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A big tabular-mono number with a mono caption underneath (§2.7), e.g.
/// the Plan detail stats strip (47 / 92% / 12 / 3).
class LStat extends StatelessWidget {
  const LStat({required this.value, required this.caption, super.key});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: context.textStyles.statNumber.copyWith(color: colors.neutrals.ink)),
        Text(
          caption,
          style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2),
        ),
      ],
    );
  }
}
