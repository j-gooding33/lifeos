import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// Last 5 created items (§5.3). Tasks only until other creatable entities
/// exist.
class RecentCard extends StatelessWidget {
  const RecentCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.recent.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Recent'),
          const SizedBox(height: LifeSpace.s8),
          for (final task in snapshot.recent)
            InkWell(
              onTap: () => context.push(Routes.taskDetail.replaceFirst(':id', task.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
                child: Text(
                  task.title,
                  style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
