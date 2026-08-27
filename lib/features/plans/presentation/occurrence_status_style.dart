import 'package:flutter/material.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// One glyph/colour/label per occurrence status (§7.5 history, §8.2
/// calendar cells) — shared so every place that renders a status agrees.
/// "Moved" isn't its own [OccurrenceStatus] (see the enum's doc comment);
/// render it by checking `originalDate != null` alongside `pending`
/// separately at the call site.
IconData occurrenceStatusIcon(OccurrenceStatus status) => switch (status) {
  OccurrenceStatus.completed => Icons.check_circle,
  OccurrenceStatus.missed => Icons.cancel_outlined,
  OccurrenceStatus.skipped => Icons.skip_next,
  OccurrenceStatus.cancelled => Icons.remove_circle_outline,
  OccurrenceStatus.pending => Icons.circle_outlined,
};

Color occurrenceStatusColor(BuildContext context, OccurrenceStatus status) {
  final colors = context.colors;
  return switch (status) {
    OccurrenceStatus.completed => colors.semantic('success').base,
    OccurrenceStatus.missed => colors.semantic('danger').base,
    OccurrenceStatus.skipped => colors.neutrals.ink3,
    OccurrenceStatus.cancelled => colors.neutrals.ink3,
    OccurrenceStatus.pending => colors.neutrals.ink3,
  };
}

String occurrenceStatusLabel(OccurrenceStatus status) => switch (status) {
  OccurrenceStatus.completed => 'done',
  OccurrenceStatus.missed => 'missed',
  OccurrenceStatus.skipped => 'skipped',
  OccurrenceStatus.cancelled => 'cancelled',
  OccurrenceStatus.pending => 'pending',
};
