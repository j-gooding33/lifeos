import 'package:flutter/material.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// Icon, one line of "what this is for", one line of "what to do", one
/// action (§2.7, §2.8). Copy comes from the §30 deck at the call site.
class LEmptyState extends StatelessWidget {
  const LEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LifeSpace.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colors.neutrals.ink3),
            const SizedBox(height: LifeSpace.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink),
            ),
            const SizedBox(height: LifeSpace.s4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: LifeSpace.s20),
              LButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
