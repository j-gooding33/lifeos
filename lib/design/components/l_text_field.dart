import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A single-line text field styled on `surfaceAlt` (§2.7).
class LTextField extends StatelessWidget {
  const LTextField({
    this.controller,
    this.placeholder,
    this.onChanged,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: context.textStyles.body.copyWith(color: colors.neutrals.ink3),
        filled: true,
        fillColor: colors.neutrals.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LifeRadius.control),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
