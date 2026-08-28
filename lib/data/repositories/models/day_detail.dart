import 'package:life_os/core/scheduling/civil_date.dart';

class DayDetailTask {
  const DayDetailTask({required this.title, required this.isCompleted});
  final String title;
  final bool isCompleted;
}

class DayDetailOccurrence {
  const DayDetailOccurrence({required this.title, required this.status, this.scheduledTime});
  final String title;
  final String status;
  final String? scheduledTime;
}

/// §21.2's day detail — the same data backs `/home/day/:date` and a tapped
/// cell on Your Year, "so it is built once" (the spec's own words).
class DayDetail {
  const DayDetail({
    required this.date,
    required this.tasks,
    required this.occurrences,
    required this.filmsWatched,
    required this.booksFinished,
    required this.journalWritten,
    required this.goalsProgressed,
  });

  final CivilDate date;
  final List<DayDetailTask> tasks;
  final List<DayDetailOccurrence> occurrences;
  final List<String> filmsWatched;
  final List<String> booksFinished;
  final bool journalWritten;
  final int goalsProgressed;

  int get tasksCompleted => tasks.where((t) => t.isCompleted).length;

  bool get isEmpty =>
      tasks.isEmpty && occurrences.isEmpty && filmsWatched.isEmpty && booksFinished.isEmpty && !journalWritten && goalsProgressed == 0;
}
