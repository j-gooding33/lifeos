import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A compact +/- numeric stepper (§7.3's rhythm editor, and the details
/// step's duration field) — avoids free-text numeric parsing/validation.
class StepControl extends StatelessWidget {
  const StepControl({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 365,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: context.textStyles.mono.copyWith(color: colors.neutrals.ink),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
