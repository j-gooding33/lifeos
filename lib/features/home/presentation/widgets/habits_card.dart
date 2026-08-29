import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/first_value.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_progress_ring.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `habits` — a row of rings, tap to complete today's occurrence.
class HabitsCard extends ConsumerWidget {
  const HabitsCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (snapshot.habits.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Habits'),
          const SizedBox(height: LifeSpace.s12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final habit in snapshot.habits)
                  Padding(
                    padding: const EdgeInsets.only(right: LifeSpace.s16),
                    child: GestureDetector(
                      onTap: () => _toggle(ref, habit),
                      onLongPress: () => context.push(Routes.planDetail.replaceFirst(':id', habit.plan.id)),
                      child: Column(
                        children: [
                          LProgressRing(
                            value: habit.completedToday ? 1 : 0,
                            size: 48,
                            semanticLabel: habit.plan.title,
                            child: habit.completedToday ? Icon(Icons.check, size: 20, color: colors.accent.base) : null,
                          ),
                          const SizedBox(height: LifeSpace.s4),
                          SizedBox(
                            width: 56,
                            child: Text(
                              habit.plan.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, HabitRingItem habit) async {
    final repository = ref.read(homePlanRepositoryProvider);
    final today = CivilDate.fromDateTime(DateTime.now());
    final occurrence = await firstValue(repository.watchOccurrenceOn(habit.plan.id, today));
    if (occurrence == null) return;
    if (habit.completedToday) {
      await repository.uncompleteOccurrence(occurrence, habit.plan);
    } else {
      await repository.completeOccurrence(occurrence, habit.plan);
    }
  }
}
