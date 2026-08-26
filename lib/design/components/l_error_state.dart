import 'package:flutter/material.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// Error-state equivalent of `LEmptyState` (§2.7, §2.8) — a retry action,
/// never a raw exception message.
class LErrorState extends StatelessWidget {
  const LErrorState({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LifeSpace.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: colors.semantic('danger').base),
            const SizedBox(height: LifeSpace.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: LifeSpace.s20),
              LButton(label: 'Try again', onPressed: onRetry, variant: LButtonVariant.tonal),
            ],
          ],
        ),
      ),
    );
  }
}
