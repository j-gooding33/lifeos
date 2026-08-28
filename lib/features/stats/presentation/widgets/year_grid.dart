import 'package:flutter/material.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

const _opacityByScore = [0.0, 0.18, 0.42, 0.68, 1.0];
const _cellSize = 11.0;
const _gap = 3.0;

/// §21.1, §21.3: "365 cells must not be 365 widgets rebuilding" — one
/// `CustomPainter` over the whole year, not a `Container` per day (the way
/// `LHeatmapGrid` does it, fine at 12 cells, not at 365). Weeks are
/// columns, weekdays are rows, exactly as specified.
class YearGrid extends StatefulWidget {
  const YearGrid({
    required this.year,
    required this.activityScores,
    required this.milestoneDates,
    required this.onSelectDay,
    super.key,
  });

  final int year;
  final Map<CivilDate, int> activityScores;
  final Set<CivilDate> milestoneDates;
  final ValueChanged<CivilDate> onSelectDay;

  @override
  State<YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<YearGrid> {
  late final _weekStart = CivilDate(widget.year, 1, 1).startOfWeek();
  late final _lastDay = CivilDate(widget.year, 12, 31);
  late final _columns = (CivilDate.daysBetween(_weekStart, _lastDay) ~/ 7) + 1;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition) {
    final col = (localPosition.dx / (_cellSize + _gap)).floor();
    final row = (localPosition.dy / (_cellSize + _gap)).floor();
    if (col < 0 || col >= _columns || row < 0 || row > 6) return;
    final date = _weekStart.addDays(col * 7 + row);
    if (date.year != widget.year) return;
    widget.onSelectDay(date);
  }

  @override
  Widget build(BuildContext context) {
    final width = _columns * (_cellSize + _gap) - _gap;
    const height = 7 * (_cellSize + _gap) - _gap;
    final colors = context.colors;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details.localPosition),
        child: CustomPaint(
          size: Size(width, height),
          painter: _YearGridPainter(
            weekStart: _weekStart,
            year: widget.year,
            columns: _columns,
            activityScores: widget.activityScores,
            milestoneDates: widget.milestoneDates,
            today: CivilDate.fromDateTime(DateTime.now()),
            accentColour: colors.accent.base,
            trackColour: colors.neutrals.surfaceSunken,
            ringColour: colors.neutrals.ink,
          ),
        ),
      ),
    );
  }
}

class _YearGridPainter extends CustomPainter {
  _YearGridPainter({
    required this.weekStart,
    required this.year,
    required this.columns,
    required this.activityScores,
    required this.milestoneDates,
    required this.today,
    required this.accentColour,
    required this.trackColour,
    required this.ringColour,
  });

  final CivilDate weekStart;
  final int year;
  final int columns;
  final Map<CivilDate, int> activityScores;
  final Set<CivilDate> milestoneDates;
  final CivilDate today;
  final Color accentColour;
  final Color trackColour;
  final Color ringColour;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = trackColour;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = ringColour;
    final notchPaint = Paint()..color = ringColour;

    for (var col = 0; col < columns; col++) {
      for (var row = 0; row < 7; row++) {
        final date = weekStart.addDays(col * 7 + row);
        if (date.year != year) continue;

        final rect = Rect.fromLTWH(col * (_cellSize + _gap), row * (_cellSize + _gap), _cellSize, _cellSize);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

        if (date.isAfter(today)) {
          canvas.drawRRect(rrect, borderPaint);
        } else {
          final score = activityScores[date] ?? 0;
          fillPaint.color = score == 0 ? trackColour : accentColour.withValues(alpha: _opacityByScore[score]);
          canvas.drawRRect(rrect, fillPaint);
        }

        if (date == today) {
          canvas.drawRRect(rrect.deflate(0.75), ringPaint);
        }

        if (milestoneDates.contains(date)) {
          final notch = Path()
            ..moveTo(rect.right - 4, rect.top)
            ..lineTo(rect.right, rect.top)
            ..lineTo(rect.right, rect.top + 4)
            ..close();
          canvas.drawPath(notch, notchPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_YearGridPainter oldDelegate) =>
      oldDelegate.activityScores != activityScores || oldDelegate.milestoneDates != milestoneDates || oldDelegate.today != today;
}
