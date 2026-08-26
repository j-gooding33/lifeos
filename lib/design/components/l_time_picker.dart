import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A tappable field that opens the platform time picker (§2.7).
class LTimePicker extends StatelessWidget {
  const LTimePicker({required this.time, required this.onChanged, super.key});

  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = time == null
        ? 'Select a time'
        : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
    return Material(
      color: colors.neutrals.surfaceAlt,
      borderRadius: BorderRadius.circular(LifeRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(LifeRadius.control),
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 16, color: colors.neutrals.ink2),
              const SizedBox(width: LifeSpace.s8),
              Text(label, style: context.textStyles.mono.copyWith(color: colors.neutrals.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
