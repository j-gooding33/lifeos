import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_task.dart';

/// §19.9's `/home/briefing/:period`. Only two periods exist — there's no
/// third "any time" briefing.
enum BriefingPeriod { morning, evening }

/// A contiguous free slot for the morning briefing's "free-time windows".
class FreeTimeWindow {
  const FreeTimeWindow(this.start, this.end);

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

/// Pure — merges [busy] intervals and returns the gaps between them (and
/// before the first / after the last, bounded by [dayStart]/[dayEnd])
/// that are at least [minimum] long. §19.9: "free-time windows come from
/// local queries" — this is that computation, independent of where the
/// intervals came from (calendar events, timed plan occurrences, ...).
List<FreeTimeWindow> freeTimeWindows({
  required List<(DateTime start, DateTime end)> busy,
  required DateTime dayStart,
  required DateTime dayEnd,
  Duration minimum = const Duration(minutes: 30),
}) {
  if (!dayStart.isBefore(dayEnd)) return const [];

  final sorted = [...busy.where((b) => b.$2.isAfter(b.$1))]..sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(DateTime, DateTime)>[];
  for (final interval in sorted) {
    if (merged.isNotEmpty && !interval.$1.isAfter(merged.last.$2)) {
      final last = merged.removeLast();
      merged.add((last.$1, interval.$2.isAfter(last.$2) ? interval.$2 : last.$2));
    } else {
      merged.add(interval);
    }
  }

  final windows = <FreeTimeWindow>[];
  var cursor = dayStart;
  for (final (busyStart, busyEnd) in merged) {
    final clampedStart = busyStart.isBefore(dayStart) ? dayStart : busyStart;
    final clampedEnd = busyEnd.isAfter(dayEnd) ? dayEnd : busyEnd;
    if (clampedEnd.isBefore(clampedStart) || clampedEnd.isBefore(cursor)) continue;
    if (clampedStart.isAfter(cursor) && clampedStart.difference(cursor) >= minimum) {
      windows.add(FreeTimeWindow(cursor, clampedStart));
    }
    if (clampedEnd.isAfter(cursor)) cursor = clampedEnd;
  }
  if (cursor.isBefore(dayEnd) && dayEnd.difference(cursor) >= minimum) {
    windows.add(FreeTimeWindow(cursor, dayEnd));
  }
  return windows;
}

/// Pure — the soonest incomplete task with a due date, among [tasks].
/// Same-day ties go to the one with an actual time set (an untimed task
/// due "today" sorts as end-of-day — it isn't looming the way a 9am one
/// is). `null` when nothing has a due date at all.
AppTask? nearestDeadline(List<AppTask> tasks) {
  final candidates = tasks.where((t) => t.completedAt == null && t.dueDate != null).toList()
    ..sort((a, b) {
      final byDate = a.dueDate!.compareTo(b.dueDate!);
      if (byDate != 0) return byDate;
      return (a.dueTime ?? '23:59').compareTo(b.dueTime ?? '23:59');
    });
  return candidates.firstOrNull;
}

/// Combines a [date] with a `"HH:mm"` wall time into a real `DateTime`.
/// `null` if [time] isn't parseable — callers treat that occurrence/task
/// as having no fixed slot, not a fabricated one.
DateTime? civilDateTimeAt(CivilDate date, String? time) {
  if (time == null) return null;
  final parts = time.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

/// Deterministic — no AI call. §19.9: "if AI is off or offline, the
/// briefing still renders with a plain deterministic sentence... the
/// briefing must work without the network." Since there's no AI backend
/// wired up yet at all (see the Settings → AI decision), this sentence
/// isn't a fallback here, it's the only sentence — which is exactly the
/// behaviour the spec requires in that case anyway.
String morningSentence({required int taskCount, required int occurrenceCount, required AppTask? nearestDeadline}) {
  final bits = <String>[];
  if (taskCount > 0) bits.add('$taskCount task${taskCount == 1 ? '' : 's'}');
  if (occurrenceCount > 0) bits.add('$occurrenceCount plan${occurrenceCount == 1 ? '' : 's'}');
  final headline = bits.isEmpty ? 'Nothing scheduled today.' : 'You have ${bits.join(' and ')} today.';
  if (nearestDeadline == null) return headline;
  return '$headline ${nearestDeadline.title} is the nearest deadline.';
}

/// Deterministic, same reasoning as [morningSentence].
String eveningSentence({required int completedCount, required int tomorrowCount}) {
  final first = completedCount > 0
      ? 'You completed $completedCount thing${completedCount == 1 ? '' : 's'} today.'
      : 'Nothing marked done today.';
  final second = tomorrowCount > 0
      ? 'Tomorrow has $tomorrowCount thing${tomorrowCount == 1 ? '' : 's'} lined up.'
      : 'Nothing on tomorrow yet.';
  return '$first $second';
}
