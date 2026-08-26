import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A `micro`-scale uppercase section label with an optional trailing
/// action (§2.7), e.g. "PLANS TODAY" above a card.
class LSectionHeader extends StatelessWidget {
  const LSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: context.textStyles.micro.copyWith(color: colors.neutrals.ink3),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
