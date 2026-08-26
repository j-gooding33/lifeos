import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A leading/title/subtitle/trailing row (§2.7), the workhorse list item
/// across Tasks, Plans, Library, etc.
class LListTile extends StatelessWidget {
  const LListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LifeSpace.s16,
              vertical: LifeSpace.s8,
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: LifeSpace.s12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: textStyles.body.copyWith(color: colors.neutrals.ink),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: textStyles.caption.copyWith(color: colors.neutrals.ink2),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: LifeSpace.s12), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
