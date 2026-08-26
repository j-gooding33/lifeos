import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A tappable field that opens the platform date picker, themed to the
/// design tokens (§2.7). The picker itself reuses Flutter's built-in
/// `showDatePicker` rather than reinventing calendar-grid math.
class LDatePicker extends StatelessWidget {
  const LDatePicker({
    required this.date,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = date == null
        ? 'Select a date'
        : '${date!.year.toString().padLeft(4, '0')}-'
            '${date!.month.toString().padLeft(2, '0')}-'
            '${date!.day.toString().padLeft(2, '0')}';
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
              Icon(Icons.calendar_today, size: 16, color: colors.neutrals.ink2),
              const SizedBox(width: LifeSpace.s8),
              Text(
                label,
                style: context.textStyles.mono.copyWith(color: colors.neutrals.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
