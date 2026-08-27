import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/routing/routes.dart';

class _QuickAddType {
  const _QuickAddType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// §6.2's type picker — the Layer 1/Layer 2 natural-language capture and
/// the "Ask AI" entry point are separate, larger pieces of work (a
/// 120-case parser suite and an AI proxy respectively) sequenced after
/// this; see DECISIONS.md. Only "Task", "Plan" and "Habit" actually create
/// anything yet — every other type honestly says so rather than opening
/// something that doesn't exist (CLAUDE.md rule 1).
class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  static const _primary = [
    _QuickAddType('Task', Icons.check_circle_outline),
    _QuickAddType('Event', Icons.event_outlined),
    _QuickAddType('Plan', Icons.repeat_outlined),
    _QuickAddType('Habit', Icons.track_changes_outlined),
    _QuickAddType('Goal', Icons.flag_outlined),
    _QuickAddType('Project', Icons.folder_outlined),
  ];

  static const _secondary = ['Note', 'Film', 'Book', 'Expense', 'Journal', 'Reminder'];

  static Future<void> show(BuildContext context) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.4],
      builder: (context) => const QuickAddSheet(),
    );
  }

  void _select(BuildContext context, String type) {
    switch (type) {
      case 'Task':
        Navigator.of(context).maybePop();
        context.push(Routes.tasksNew);
      case 'Plan':
        Navigator.of(context).maybePop();
        context.push(Routes.plansNew);
      case 'Habit':
        Navigator.of(context).maybePop();
        context.push(Routes.habitsNew);
      default:
        LToast.show(context, "$type creation is on the roadmap but hasn't shipped.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you adding?',
            style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
          ),
          const SizedBox(height: LifeSpace.s16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: LifeSpace.s12,
            crossAxisSpacing: LifeSpace.s12,
            childAspectRatio: 2.4,
            children: [
              for (final type in _primary)
                _PrimaryTile(type: type, onTap: () => _select(context, type.label)),
            ],
          ),
          const SizedBox(height: LifeSpace.s16),
          Wrap(
            spacing: LifeSpace.s8,
            runSpacing: LifeSpace.s8,
            children: [
              for (final label in _secondary)
                LChip(label: label, onTap: () => _select(context, label)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryTile extends StatelessWidget {
  const _PrimaryTile({required this.type, required this.onTap});

  final _QuickAddType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.neutrals.surfaceAlt,
      borderRadius: BorderRadius.circular(LifeRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(LifeRadius.control),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
          child: Row(
            children: [
              Icon(type.icon, color: colors.accent.base),
              const SizedBox(width: LifeSpace.s12),
              Text(type.label, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
