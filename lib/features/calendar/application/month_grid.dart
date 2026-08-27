import 'package:life_os/core/scheduling/civil_date.dart';

/// The full 7×N grid a month view renders, including the leading/trailing
/// days from adjacent months needed to fill whole weeks. Shared by the
/// single-plan calendar (§8.2) and the unified calendar (§14.2) so both
/// grids line up the same way.
(CivilDate start, CivilDate end) monthGridBounds(CivilDate monthStart) {
  final gridStart = monthStart.startOfWeek();
  final daysInMonth = CivilDate.daysInMonth(monthStart.year, monthStart.month);
  final monthEnd = CivilDate(monthStart.year, monthStart.month, daysInMonth);
  final weeksNeeded =
      (CivilDate.daysBetween(gridStart, monthEnd.startOfWeek()) ~/ 7) + 1;
  return (gridStart, gridStart.addDays(weeksNeeded * 7 - 1));
}
