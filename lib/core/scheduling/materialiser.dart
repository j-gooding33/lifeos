import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';

enum MaterialisedStatus { pending, cancelled }

/// One desired occurrence, before the caller assigns it a real id/row.
/// Deliberately doesn't know about Drift or uuidV5 — id assignment is a
/// data-layer concern (§9.7) so this stays pure and just describes *what*
/// should exist.
class MaterialisedOccurrence {
  const MaterialisedOccurrence(this.date, this.status);
  final CivilDate date;
  final MaterialisedStatus status;
}

/// An occurrence the caller already has in the database, passed in so
/// regeneration can preserve exceptions (§8.6, golden case 21) instead of
/// wiping out deliberate reschedules.
class ExistingOccurrence {
  const ExistingOccurrence(this.date, {required this.isException});
  final CivilDate date;
  final bool isException;
}

/// §9.5. Generates the desired occurrence set for a plan up to a horizon
/// date. Pure — the caller (a repository) diffs this against the database
/// and does the actual insert/update, which is also where deterministic
/// ids (§9.7) get assigned.
class Materialiser {
  const Materialiser({RecurrenceEngine? engine}) : _engine = engine ?? const RecurrenceEngine();

  final RecurrenceEngine _engine;

  static const horizonDaysActive = 120;
  static const horizonDaysBackground = 60;
  static const maxOccurrencesPerPlan = 5000;

  /// Returns every occurrence that should exist from the rule's anchor
  /// through [through], preserving any [existing] exception at its
  /// original date and applying [pauseFrom]..[pauseUntil] as cancelled
  /// (§8.6 pause window, golden case 24).
  List<MaterialisedOccurrence> materialise({
    required RecurrenceRule rule,
    required CivilDate through,
    List<ExistingOccurrence> existing = const [],
    CivilDate? pauseFrom,
    CivilDate? pauseUntil,
    bool weekStartsMonday = true,
  }) {
    final exceptionDates = {
      for (final e in existing.where((e) => e.isException)) e.date: e,
    };

    final window = DateRange(rule.anchor, through);
    final generatedDates = _engine.datesIn(rule, window, weekStartsMonday: weekStartsMonday);

    final result = <MaterialisedOccurrence>[];
    var count = 0;
    for (final date in generatedDates) {
      if (count >= maxOccurrencesPerPlan) break;
      if (exceptionDates.containsKey(date)) {
        // The exception itself is preserved by the caller (it already
        // exists); we don't emit a second row for the same date.
        continue;
      }
      final paused = pauseFrom != null &&
          pauseUntil != null &&
          date.isAtOrAfter(pauseFrom) &&
          date.isAtOrBefore(pauseUntil);
      result.add(
        MaterialisedOccurrence(date, paused ? MaterialisedStatus.cancelled : MaterialisedStatus.pending),
      );
      count++;
    }
    return result;
  }
}
