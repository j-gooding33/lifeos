/// §23.3. Shared across domains — `domain` is `'task' | 'plan' | 'expense'`
/// — this model is used for the `'expense'` domain only so far.
class AppCategory {
  AppCategory({
    required this.id,
    required this.userId,
    required this.domain,
    required this.name,
    this.colour,
    this.icon,
    this.sortIndex,
  });

  final String id;
  final String userId;
  final String domain;
  final String name;
  final String? colour;
  final String? icon;
  final double? sortIndex;
}
