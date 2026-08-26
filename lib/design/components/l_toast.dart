import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A transient toast (§2.7), e.g. the 10-second AI-undo notice or a "Next:
/// 26 September" confirmation. Built on `ScaffoldMessenger` rather than a
/// bespoke overlay stack, so it composes with existing snack bars.
class LToast {
  const LToast._();

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = context.colors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: colors.neutrals.ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LifeRadius.control)),
          behavior: SnackBarBehavior.floating,
          content: Text(message, style: context.textStyles.body.copyWith(color: colors.neutrals.bg)),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: colors.accent.base,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}
