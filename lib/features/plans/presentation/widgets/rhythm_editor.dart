import 'package:flutter/material.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/presentation/widgets/step_control.dart';

enum _Preset {
  everyDay,
  everyOtherDay,
  every3Days,
  weekly,
  specificDays,
  custom,
}

enum _SimpleUnit { days, weeks, months }

enum _CustomType {
  intervalDays,
  weeklyDays,
  monthlyDay,
  monthlyWeekday,
  yearly,
  customDates,
  timesPerPeriod,
}

const _weekdayLabels = {
  Weekday.monday: 'Mon',
  Weekday.tuesday: 'Tue',
  Weekday.wednesday: 'Wed',
  Weekday.thursday: 'Thu',
  Weekday.friday: 'Fri',
  Weekday.saturday: 'Sat',
  Weekday.sunday: 'Sun',
};

/// §7.3 step 2 — the important screen. The six preset buttons drive one
/// shared "every N (days/weeks/months)" control for the common cases;
/// "Custom" swaps that out for the full seven-rule-type editor §9.2 asks
/// for, including `TIMES_PER_PERIOD` ("Flexible").
class RhythmEditor extends StatefulWidget {
  const RhythmEditor({
    required this.anchor,
    required this.onRuleChanged,
    this.initialRule,
    super.key,
  });

  final CivilDate anchor;
  final RecurrenceRule? initialRule;
  final ValueChanged<RecurrenceRule> onRuleChanged;

  @override
  State<RhythmEditor> createState() => _RhythmEditorState();
}

class _RhythmEditorState extends State<RhythmEditor> {
  var _preset = _Preset.everyDay;
  var _simpleUnit = _SimpleUnit.days;
  var _simpleN = 1;
  var _specificDays = <Weekday>{};
  var _customType = _CustomType.intervalDays;
  var _customIntervalN = 1;
  var _customWeeklyDays = <Weekday>{};
  var _customEveryNWeeks = 1;
  var _customDayOfMonth = 1;
  var _customEveryNMonths = 1;
  var _customNth = 1;
  var _customWeekday = Weekday.monday;
  var _customMonth = 1;
  var _customYearDay = 1;
  var _customDates = <CivilDate>[];
  var _customTimes = 3;
  var _customPeriod = Period.week;

  @override
  void initState() {
    super.initState();
    _specificDays = {Weekday.fromIso(widget.anchor.isoWeekday)};
    _customWeeklyDays = {Weekday.fromIso(widget.anchor.isoWeekday)};
    _customWeekday = Weekday.fromIso(widget.anchor.isoWeekday);
    _customDayOfMonth = widget.anchor.day;
    _customMonth = widget.anchor.month;
    _customYearDay = widget.anchor.day;
    if (widget.initialRule != null) _seedFrom(widget.initialRule!);
    _notify();
  }

  void _seedFrom(RecurrenceRule rule) {
    switch (rule) {
      case IntervalDays(:final n):
        _preset = switch (n) {
          1 => _Preset.everyDay,
          2 => _Preset.everyOtherDay,
          3 => _Preset.every3Days,
          _ => _Preset.custom,
        };
        _simpleUnit = _SimpleUnit.days;
        _simpleN = n;
        _customType = _CustomType.intervalDays;
        _customIntervalN = n;
      case WeeklyDays(:final days, :final everyNWeeks):
        _preset = _Preset.specificDays;
        _specificDays = days;
        _customType = _CustomType.weeklyDays;
        _customWeeklyDays = days;
        _customEveryNWeeks = everyNWeeks;
      case MonthlyDay(:final dayOfMonth, :final everyNMonths):
        _preset = _Preset.custom;
        _customType = _CustomType.monthlyDay;
        _customDayOfMonth = dayOfMonth;
        _customEveryNMonths = everyNMonths;
      case MonthlyWeekday(:final nth, :final day, :final everyNMonths):
        _preset = _Preset.custom;
        _customType = _CustomType.monthlyWeekday;
        _customNth = nth;
        _customWeekday = day;
        _customEveryNMonths = everyNMonths;
      case Yearly(:final month, :final day):
        _preset = _Preset.custom;
        _customType = _CustomType.yearly;
        _customMonth = month;
        _customYearDay = day;
      case CustomDates(:final dates):
        _preset = _Preset.custom;
        _customType = _CustomType.customDates;
        _customDates = dates;
      case TimesPerPeriod(:final times, :final period):
        _preset = _Preset.custom;
        _customType = _CustomType.timesPerPeriod;
        _customTimes = times;
        _customPeriod = period;
    }
  }

  RecurrenceRule get _rule {
    if (_preset != _Preset.custom) {
      return switch (_simpleUnit) {
        _SimpleUnit.days => IntervalDays(_simpleN, anchor: widget.anchor),
        _SimpleUnit.weeks =>
          _preset == _Preset.specificDays
              ? WeeklyDays(
                  _specificDays.isEmpty
                      ? {Weekday.fromIso(widget.anchor.isoWeekday)}
                      : _specificDays,
                  anchor: widget.anchor,
                )
              : WeeklyDays(
                  {Weekday.fromIso(widget.anchor.isoWeekday)},
                  anchor: widget.anchor,
                  everyNWeeks: _simpleN,
                ),
        _SimpleUnit.months => MonthlyDay(
          widget.anchor.day,
          anchor: widget.anchor,
          everyNMonths: _simpleN,
        ),
      };
    }
    return switch (_customType) {
      _CustomType.intervalDays => IntervalDays(
        _customIntervalN,
        anchor: widget.anchor,
      ),
      _CustomType.weeklyDays => WeeklyDays(
        _customWeeklyDays.isEmpty
            ? {Weekday.fromIso(widget.anchor.isoWeekday)}
            : _customWeeklyDays,
        anchor: widget.anchor,
        everyNWeeks: _customEveryNWeeks,
      ),
      _CustomType.monthlyDay => MonthlyDay(
        _customDayOfMonth,
        anchor: widget.anchor,
        everyNMonths: _customEveryNMonths,
      ),
      _CustomType.monthlyWeekday => MonthlyWeekday(
        _customNth,
        _customWeekday,
        anchor: widget.anchor,
        everyNMonths: _customEveryNMonths,
      ),
      _CustomType.yearly => Yearly(
        _customMonth,
        _customYearDay,
        anchor: widget.anchor,
      ),
      _CustomType.customDates => CustomDates(
        _customDates.isEmpty ? [widget.anchor] : _customDates,
        anchor: widget.anchor,
      ),
      _CustomType.timesPerPeriod => TimesPerPeriod(
        _customTimes,
        _customPeriod,
        anchor: widget.anchor,
      ),
    };
  }

  void _notify() => widget.onRuleChanged(_rule);

  void _selectPreset(_Preset preset) {
    setState(() {
      _preset = preset;
      switch (preset) {
        case _Preset.everyDay:
          _simpleUnit = _SimpleUnit.days;
          _simpleN = 1;
        case _Preset.everyOtherDay:
          _simpleUnit = _SimpleUnit.days;
          _simpleN = 2;
        case _Preset.every3Days:
          _simpleUnit = _SimpleUnit.days;
          _simpleN = 3;
        case _Preset.weekly:
          _simpleUnit = _SimpleUnit.weeks;
          _simpleN = 1;
        case _Preset.specificDays:
          _simpleUnit = _SimpleUnit.weeks;
          _simpleN = 1;
        case _Preset.custom:
          break;
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often?',
          style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
        ),
        const SizedBox(height: LifeSpace.s12),
        Wrap(
          spacing: LifeSpace.s8,
          runSpacing: LifeSpace.s8,
          children: [
            _presetChip('Every day', _Preset.everyDay),
            _presetChip('Every other day', _Preset.everyOtherDay),
            _presetChip('Every 3 days', _Preset.every3Days),
            _presetChip('Weekly', _Preset.weekly),
            _presetChip('Specific days', _Preset.specificDays),
            _presetChip('Custom', _Preset.custom),
          ],
        ),
        const SizedBox(height: LifeSpace.s20),
        if (_preset == _Preset.specificDays) _buildWeekdayPicker(),
        if (_preset != _Preset.custom && _preset != _Preset.specificDays)
          _buildSimpleEditor(),
        if (_preset == _Preset.custom) _buildCustomEditor(),
        const SizedBox(height: LifeSpace.s20),
        _buildPreview(context),
      ],
    );
  }

  Widget _presetChip(String label, _Preset preset) {
    return LChip(
      label: label,
      selected: _preset == preset,
      onTap: () => _selectPreset(preset),
    );
  }

  Widget _buildWeekdayPicker() {
    return Wrap(
      spacing: LifeSpace.s8,
      children: [
        for (final day in Weekday.values)
          LChip(
            label: _weekdayLabels[day]!,
            selected: _specificDays.contains(day),
            onTap: () {
              setState(() {
                if (_specificDays.contains(day)) {
                  if (_specificDays.length > 1) _specificDays.remove(day);
                } else {
                  _specificDays.add(day);
                }
              });
              _notify();
            },
          ),
      ],
    );
  }

  Widget _buildSimpleEditor() {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          'Every',
          style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
        ),
        const SizedBox(width: LifeSpace.s8),
        StepControl(
          value: _simpleN,
          onChanged: (n) {
            setState(() => _simpleN = n);
            _notify();
          },
        ),
        const SizedBox(width: LifeSpace.s8),
        DropdownButton<_SimpleUnit>(
          value: _simpleUnit,
          items: const [
            DropdownMenuItem(value: _SimpleUnit.days, child: Text('days')),
            DropdownMenuItem(value: _SimpleUnit.weeks, child: Text('weeks')),
            DropdownMenuItem(value: _SimpleUnit.months, child: Text('months')),
          ],
          onChanged: (unit) {
            if (unit == null) return;
            setState(() => _simpleUnit = unit);
            _notify();
          },
        ),
      ],
    );
  }

  Widget _buildCustomEditor() {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<_CustomType>(
          value: _customType,
          items: const [
            DropdownMenuItem(
              value: _CustomType.intervalDays,
              child: Text('Every N days'),
            ),
            DropdownMenuItem(
              value: _CustomType.weeklyDays,
              child: Text('Specific weekdays'),
            ),
            DropdownMenuItem(
              value: _CustomType.monthlyDay,
              child: Text('Day of month'),
            ),
            DropdownMenuItem(
              value: _CustomType.monthlyWeekday,
              child: Text('Nth weekday of month'),
            ),
            DropdownMenuItem(value: _CustomType.yearly, child: Text('Yearly')),
            DropdownMenuItem(
              value: _CustomType.customDates,
              child: Text('Specific dates'),
            ),
            DropdownMenuItem(
              value: _CustomType.timesPerPeriod,
              child: Text('Flexible (times per period)'),
            ),
          ],
          onChanged: (type) {
            if (type == null) return;
            setState(() => _customType = type);
            _notify();
          },
        ),
        const SizedBox(height: LifeSpace.s12),
        switch (_customType) {
          _CustomType.intervalDays => Row(
            children: [
              Text(
                'Every',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink2,
                ),
              ),
              const SizedBox(width: LifeSpace.s8),
              StepControl(
                value: _customIntervalN,
                onChanged: (n) {
                  setState(() => _customIntervalN = n);
                  _notify();
                },
              ),
              const SizedBox(width: LifeSpace.s8),
              Text(
                'days',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink2,
                ),
              ),
            ],
          ),
          _CustomType.weeklyDays => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: LifeSpace.s8,
                children: [
                  for (final day in Weekday.values)
                    LChip(
                      label: _weekdayLabels[day]!,
                      selected: _customWeeklyDays.contains(day),
                      onTap: () {
                        setState(() {
                          if (_customWeeklyDays.contains(day)) {
                            if (_customWeeklyDays.length > 1) {
                              _customWeeklyDays.remove(day);
                            }
                          } else {
                            _customWeeklyDays.add(day);
                          }
                        });
                        _notify();
                      },
                    ),
                ],
              ),
              const SizedBox(height: LifeSpace.s12),
              Row(
                children: [
                  Text(
                    'Every',
                    style: context.textStyles.body.copyWith(
                      color: colors.neutrals.ink2,
                    ),
                  ),
                  const SizedBox(width: LifeSpace.s8),
                  StepControl(
                    value: _customEveryNWeeks,
                    onChanged: (n) {
                      setState(() => _customEveryNWeeks = n);
                      _notify();
                    },
                  ),
                  const SizedBox(width: LifeSpace.s8),
                  Text(
                    'weeks',
                    style: context.textStyles.body.copyWith(
                      color: colors.neutrals.ink2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _CustomType.monthlyDay => Row(
            children: [
              Text(
                'Day',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink2,
                ),
              ),
              const SizedBox(width: LifeSpace.s8),
              StepControl(
                value: _customDayOfMonth,
                min: -1,
                max: 31,
                onChanged: (n) {
                  setState(() => _customDayOfMonth = n.clamp(-1, 31));
                  _notify();
                },
              ),
              const SizedBox(width: LifeSpace.s8),
              Text(
                _customDayOfMonth == -1 ? '(last day)' : 'of every',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink2,
                ),
              ),
              const SizedBox(width: LifeSpace.s8),
              StepControl(
                value: _customEveryNMonths,
                onChanged: (n) {
                  setState(() => _customEveryNMonths = n);
                  _notify();
                },
              ),
              const SizedBox(width: LifeSpace.s8),
              Text(
                'months',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink2,
                ),
              ),
            ],
          ),
          _CustomType.monthlyWeekday => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton<int>(
                    value: _customNth,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1st')),
                      DropdownMenuItem(value: 2, child: Text('2nd')),
                      DropdownMenuItem(value: 3, child: Text('3rd')),
                      DropdownMenuItem(value: 4, child: Text('4th')),
                      DropdownMenuItem(value: -1, child: Text('Last')),
                    ],
                    onChanged: (n) {
                      if (n == null) return;
                      setState(() => _customNth = n);
                      _notify();
                    },
                  ),
                  const SizedBox(width: LifeSpace.s8),
                  DropdownButton<Weekday>(
                    value: _customWeekday,
                    items: [
                      for (final day in Weekday.values)
                        DropdownMenuItem(
                          value: day,
                          child: Text(_weekdayLabels[day]!),
                        ),
                    ],
                    onChanged: (day) {
                      if (day == null) return;
                      setState(() => _customWeekday = day);
                      _notify();
                    },
                  ),
                ],
              ),
              const SizedBox(height: LifeSpace.s12),
              Row(
                children: [
                  Text(
                    'Every',
                    style: context.textStyles.body.copyWith(
                      color: colors.neutrals.ink2,
                    ),
                  ),
                  const SizedBox(width: LifeSpace.s8),
                  StepControl(
                    value: _customEveryNMonths,
                    onChanged: (n) {
                      setState(() => _customEveryNMonths = n);
                      _notify();
                    },
                  ),
                  const SizedBox(width: LifeSpace.s8),
                  Text(
                    'months',
                    style: context.textStyles.body.copyWith(
                      color: colors.neutrals.ink2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _CustomType.yearly => Row(
            children: [
              DropdownButton<int>(
                value: _customMonth,
                items: [
                  for (var m = 1; m <= 12; m++)
                    DropdownMenuItem(value: m, child: Text('$m')),
                ],
                onChanged: (m) {
                  if (m == null) return;
                  setState(() => _customMonth = m);
                  _notify();
                },
              ),
              const SizedBox(width: LifeSpace.s8),
              StepControl(
                value: _customYearDay,
                max: 31,
                onChanged: (n) {
                  setState(() => _customYearDay = n.clamp(1, 31));
                  _notify();
                },
              ),
            ],
          ),
          _CustomType.customDates => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: LifeSpace.s8,
                runSpacing: LifeSpace.s8,
                children: [
                  for (final date in _customDates)
                    LChip(
                      label: date.toIso(),
                      onTap: () {
                        setState(() => _customDates.remove(date));
                        _notify();
                      },
                    ),
                ],
              ),
              const SizedBox(height: LifeSpace.s8),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) return;
                  setState(
                    () => _customDates = [
                      ..._customDates,
                      CivilDate.fromDateTime(picked),
                    ],
                  );
                  _notify();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add a date'),
              ),
            ],
          ),
          _CustomType.timesPerPeriod => Row(
            children: [
              StepControl(
                value: _customTimes,
                onChanged: (n) {
                  setState(() => _customTimes = n);
                  _notify();
                },
              ),
              const SizedBox(width: LifeSpace.s8),
              Text(
                'times a',
                style: context.textStyles.body.copyWith(
                  color: colors.neutrals.ink2,
                ),
              ),
              const SizedBox(width: LifeSpace.s8),
              DropdownButton<Period>(
                value: _customPeriod,
                items: const [
                  DropdownMenuItem(value: Period.week, child: Text('week')),
                  DropdownMenuItem(value: Period.month, child: Text('month')),
                ],
                onChanged: (p) {
                  if (p == null) return;
                  setState(() => _customPeriod = p);
                  _notify();
                },
              ),
            ],
          ),
        },
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final colors = context.colors;
    const engine = RecurrenceEngine();
    final dates = _rule is TimesPerPeriod
        ? engine.datesIn(
            _rule,
            DateRange(widget.anchor, widget.anchor.addDays(60)),
          )
        : engine.next(_rule, widget.anchor.addDays(-1), 7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next dates',
          style: context.textStyles.subhead.copyWith(
            color: colors.neutrals.ink2,
          ),
        ),
        const SizedBox(height: LifeSpace.s4),
        Text(
          dates.isEmpty
              ? 'No dates in the near future'
              : dates.take(7).map((d) => d.toIso()).join(' · '),
          style: context.textStyles.mono.copyWith(color: colors.neutrals.ink),
        ),
      ],
    );
  }
}
