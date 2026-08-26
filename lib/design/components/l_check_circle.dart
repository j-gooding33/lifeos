import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/motion.dart';

/// A tappable completion circle (§2.7) — fills with the accent colour and
/// draws a check glyph on completion. Completion is never conveyed by
/// colour alone (§2.9): the check glyph is the real signal.
class LCheckCircle extends StatelessWidget {
  const LCheckCircle({
    required this.checked,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      toggled: checked,
      button: true,
      child: GestureDetector(
        onTap: () => onChanged(!checked),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: LifeMotion.micro,
              curve: LifeMotion.microCurve,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? colors.accent.base : Colors.transparent,
                border: Border.all(
                  color: checked ? colors.accent.base : colors.neutrals.ink3,
                  width: 2,
                ),
              ),
              child: checked
                  ? Icon(Icons.check, size: 16, color: colors.accent.on)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
