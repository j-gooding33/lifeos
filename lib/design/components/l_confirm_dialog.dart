import 'package:flutter/material.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A centred destructive-confirm dialog (§2.7, §3.3) — destructive confirms
/// are always a centre dialog, never a sheet.
class LConfirmDialog {
  const LConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
  }) async {
    final colors = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: colors.neutrals.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LifeRadius.card)),
          child: Padding(
            padding: const EdgeInsets.all(LifeSpace.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LifeSpace.s8),
                Text(
                  message,
                  style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LifeSpace.s24),
                Row(
                  children: [
                    Expanded(
                      child: LButton(
                        label: cancelLabel,
                        variant: LButtonVariant.plain,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: LifeSpace.s12),
                    Expanded(
                      child: LButton(
                        label: confirmLabel,
                        variant: LButtonVariant.destructive,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
