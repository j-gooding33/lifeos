import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/motion.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A segmented control (§2.7), e.g. Today/Upcoming/Overdue/Completed.
class LSegmented<T> extends StatelessWidget {
  const LSegmented({required this.segments, required this.selected, required this.onChanged, super.key});

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.neutrals.surfaceAlt,
        borderRadius: BorderRadius.circular(LifeRadius.control),
      ),
      child: Row(
        children: [
          for (final entry in segments.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: AnimatedContainer(
                  duration: LifeMotion.standard,
                  curve: LifeMotion.standardCurve,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: entry.key == selected ? colors.neutrals.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(LifeRadius.control - 4),
                  ),
                  child: Text(
                    entry.value,
                    style: context.textStyles.subhead.copyWith(
                      color: entry.key == selected ? colors.neutrals.ink : colors.neutrals.ink2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
