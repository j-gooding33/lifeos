import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `journalPrompt` — "Write today's entry." Hides itself once
/// today's entry already has content, rather than nagging.
class JournalPromptCard extends StatelessWidget {
  const JournalPromptCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.journalWrittenToday) return const SizedBox.shrink();
    final colors = context.colors;
    final today = CivilDate.fromDateTime(DateTime.now());

    return LCard(
      onTap: () => context.push(Routes.journalDate.replaceFirst(':date', today.toIso())),
      child: Row(
        children: [
          Icon(Icons.book_outlined, color: colors.accent.base),
          const SizedBox(width: LifeSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Write today's entry", style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
                Text('A line or two is enough.', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
