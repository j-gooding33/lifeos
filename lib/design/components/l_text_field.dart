import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A single-line text field styled on `surfaceAlt` (§2.7), or — with
/// [outlined] — a bordered field with a floating [label] instead, for
/// forms where the field's purpose needs to stay visible once filled in.
class LTextField extends StatelessWidget {
  const LTextField({
    this.controller,
    this.placeholder,
    this.label,
    this.outlined = false,
    this.onChanged,
    this.autofocus = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final bool outlined;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      keyboardType: keyboardType,
      style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: context.textStyles.body.copyWith(color: colors.neutrals.ink3),
        labelText: label,
        labelStyle: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
        filled: !outlined,
        fillColor: outlined ? null : colors.neutrals.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LifeRadius.control),
          borderSide: outlined ? BorderSide(color: colors.neutrals.border) : BorderSide.none,
        ),
        enabledBorder: outlined
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(LifeRadius.control),
                borderSide: BorderSide(color: colors.neutrals.border),
              )
            : null,
        focusedBorder: outlined
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(LifeRadius.control),
                borderSide: BorderSide(color: colors.accent.base, width: 1.5),
              )
            : null,
      ),
    );
  }
}
