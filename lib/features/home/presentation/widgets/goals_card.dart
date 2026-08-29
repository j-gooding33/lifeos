import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `goals` — up to 3 active goals with progress bars.
class GoalsCard extends StatelessWidget {
  const GoalsCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.goals.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Goals'),
          const SizedBox(height: LifeSpace.s12),
          for (final goal in snapshot.goals)
            Padding(
              padding: const EdgeInsets.only(bottom: LifeSpace.s12),
              child: InkWell(
                onTap: () => context.push(Routes.goalDetail.replaceFirst(':id', goal.id)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: context.textStyles.body.copyWith(color: colors.neutrals.ink)),
                    const SizedBox(height: LifeSpace.s4),
                    LProgressBar(value: goal.progress ?? 0, semanticLabel: goal.title),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
