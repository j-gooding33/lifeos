import 'package:flutter/material.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';

/// §7.3 step 1: "starting points, not hard-coded content" — choosing one
/// pre-fills the other steps, all still editable afterwards.
class PlanTemplate {
  const PlanTemplate({
    required this.title,
    required this.iconName,
    required this.colour,
    required this.category,
    required this.suggestedRule,
    this.mediaType,
  });

  final String title;
  final String iconName;
  final String colour;
  final String category;
  final String? mediaType;
  final RecurrenceRule Function(CivilDate anchor) suggestedRule;

  IconData get icon => planIconFor(iconName);

  static final all = <PlanTemplate>[
    PlanTemplate(
      title: 'Watch a film',
      iconName: 'movie_outlined',
      colour: 'films',
      category: 'films',
      mediaType: 'film',
      suggestedRule: (anchor) => IntervalDays(3, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Read',
      iconName: 'menu_book_outlined',
      colour: 'books',
      category: 'books',
      mediaType: 'book',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Exercise',
      iconName: 'fitness_center_outlined',
      colour: 'habits',
      category: 'exercise',
      suggestedRule: (anchor) => WeeklyDays({
        Weekday.monday,
        Weekday.wednesday,
        Weekday.friday,
      }, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Study',
      iconName: 'school_outlined',
      colour: 'study',
      category: 'study',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Practise an instrument',
      iconName: 'music_note_outlined',
      colour: 'plans',
      category: 'hobby',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Clean',
      iconName: 'cleaning_services_outlined',
      colour: 'plans',
      category: 'chores',
      suggestedRule: (anchor) => WeeklyDays({Weekday.saturday}, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Cook something new',
      iconName: 'restaurant_outlined',
      colour: 'plans',
      category: 'creative',
      suggestedRule: (anchor) => WeeklyDays({Weekday.sunday}, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Take a photo',
      iconName: 'camera_alt_outlined',
      colour: 'plans',
      category: 'creative',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Learn a language',
      iconName: 'translate_outlined',
      colour: 'study',
      category: 'study',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Call someone',
      iconName: 'call_outlined',
      colour: 'plans',
      category: 'social',
      suggestedRule: (anchor) => WeeklyDays({Weekday.sunday}, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Walk',
      iconName: 'directions_walk_outlined',
      colour: 'habits',
      category: 'exercise',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Journal',
      iconName: 'edit_note_outlined',
      colour: 'plans',
      category: 'mindfulness',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Stretch',
      iconName: 'self_improvement_outlined',
      colour: 'habits',
      category: 'mindfulness',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
    PlanTemplate(
      title: 'Custom',
      iconName: 'tune_outlined',
      colour: 'plans',
      category: 'custom',
      suggestedRule: (anchor) => IntervalDays(1, anchor: anchor),
    ),
  ];
}
