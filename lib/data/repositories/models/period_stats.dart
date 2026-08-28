/// §20.2's headline tiles and domain cards for one selected period
/// (Today/Week/Month/Year/All time).
class PeriodStats {
  const PeriodStats({
    required this.tasksCompleted,
    required this.occurrencesCompleted,
    required this.occurrencesMissed,
    required this.occurrencesSkipped,
    required this.habitsCompleted,
    required this.filmsWatched,
    required this.booksFinished,
    required this.journalDaysWritten,
    required this.goalContributions,
  });

  final int tasksCompleted;
  final int occurrencesCompleted;
  final int occurrencesMissed;
  final int occurrencesSkipped;
  final int habitsCompleted;
  final int filmsWatched;
  final int booksFinished;
  final int journalDaysWritten;
  final int goalContributions;

  int get occurrencesTotal => occurrencesCompleted + occurrencesMissed + occurrencesSkipped;

  double? get occurrenceCompletionRate => occurrencesTotal == 0 ? null : occurrencesCompleted / occurrencesTotal;
}
