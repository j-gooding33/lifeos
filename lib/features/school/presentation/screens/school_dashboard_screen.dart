import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/school/school_week_engine.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/school/application/school_providers.dart';
import 'package:life_os/routing/routes.dart';

/// M8 Part 34 — today's Week A/B, whether school's in session, and today's
/// lessons, computed fresh from the pure week-parity engine rather than
/// stored. Also the entry point into Setup/Timetable/Term dates.
class SchoolDashboardScreen extends ConsumerWidget {
  const SchoolDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final today = CivilDate.fromDateTime(DateTime.now());
    final provider = schoolDayProvider(today);
    final asyncDay = ref.watch(provider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('School'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), tooltip: 'Setup', onPressed: () => context.push(Routes.schoolSetup)),
        ],
      ),
      body: asyncDay.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load School.", onRetry: () => ref.invalidate(provider)),
        data: (snapshot) {
          if (!snapshot.hasProfile) {
            return LEmptyState(
              icon: Icons.school_outlined,
              title: 'Set up School',
              message: 'Add your day times and timetable type to get started.',
              actionLabel: 'Start setup',
              onAction: () => context.push(Routes.schoolSetup),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(LifeSpace.s16),
            children: [
              LCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Today', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
                        if (snapshot.weekLabel != null)
                          Text(
                            'Week ${snapshot.weekLabel == WeekLabel.a ? 'A' : 'B'}',
                            style: context.textStyles.mono.copyWith(color: colors.accent.base),
                          ),
                      ],
                    ),
                    const SizedBox(height: LifeSpace.s8),
                    Text(
                      snapshot.isOpen ? 'School is open today.' : 'No school today.',
                      style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LifeSpace.cardGap),
              if (snapshot.isOpen) ...[
                const LSectionHeader(title: "Today's lessons"),
                const SizedBox(height: LifeSpace.s8),
                if (snapshot.lessons.isEmpty)
                  const LEmptyState(icon: Icons.school_outlined, title: 'Nothing on the timetable', message: 'No lessons recorded for today.')
                else
                  for (final lesson in snapshot.lessons)
                    LListTile(
                      title: lesson.subject,
                      subtitle: [
                        '${lesson.startTime}-${lesson.endTime}',
                        if (lesson.teacher != null) lesson.teacher!,
                        if (lesson.room != null) lesson.room!,
                      ].join('  |  '),
                    ),
                const SizedBox(height: LifeSpace.cardGap),
              ],
              Row(
                children: [
                  Expanded(
                    child: LButton(
                      label: 'Timetable',
                      variant: LButtonVariant.tonal,
                      onPressed: () => context.push(Routes.schoolTimetable),
                    ),
                  ),
                  const SizedBox(width: LifeSpace.s12),
                  Expanded(
                    child: LButton(
                      label: 'Term dates',
                      variant: LButtonVariant.tonal,
                      onPressed: () => context.push(Routes.schoolTerms),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
