import 'package:flutter/material.dart';

/// §7.2's `icon` field is "an icon name from the app set" — a fixed string
/// key persisted in the database, resolved to a real [IconData] only here.
/// Custom emoji icons aren't supported yet (no emoji picker built); every
/// plan uses one of these named icons.
const Map<String, IconData> planIconOptions = {
  'movie_outlined': Icons.movie_outlined,
  'menu_book_outlined': Icons.menu_book_outlined,
  'fitness_center_outlined': Icons.fitness_center_outlined,
  'school_outlined': Icons.school_outlined,
  'music_note_outlined': Icons.music_note_outlined,
  'cleaning_services_outlined': Icons.cleaning_services_outlined,
  'restaurant_outlined': Icons.restaurant_outlined,
  'camera_alt_outlined': Icons.camera_alt_outlined,
  'translate_outlined': Icons.translate_outlined,
  'call_outlined': Icons.call_outlined,
  'directions_walk_outlined': Icons.directions_walk_outlined,
  'edit_note_outlined': Icons.edit_note_outlined,
  'self_improvement_outlined': Icons.self_improvement_outlined,
  'tune_outlined': Icons.tune_outlined,
  'repeat_outlined': Icons.repeat_outlined,
};

IconData planIconFor(String? name) =>
    planIconOptions[name] ?? Icons.repeat_outlined;
