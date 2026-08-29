import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_dashboard_card.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';

const _cardTypeLabels = {
  DashboardCardType.plansToday: 'Plans today',
  DashboardCardType.habits: 'Habits',
  DashboardCardType.upcoming: 'Upcoming',
  DashboardCardType.goals: 'Goals',
  DashboardCardType.projects: 'Projects',
  DashboardCardType.recent: 'Recent',
  DashboardCardType.dailyStats: 'Daily stats',
  DashboardCardType.journalPrompt: 'Journal prompt',
  DashboardCardType.spending: 'Spending',
};

const _sizeLabels = {DashboardCardSize.small: 'S', DashboardCardSize.medium: 'M', DashboardCardSize.large: 'L'};

/// §5.4. Reorderable, toggleable, sized. "Live preview at the top" isn't
/// built — see DECISIONS.md. `focus` isn't in this list at all: "always
/// first, cannot be hidden or moved" (§5.3) means it's not a row here.
class HomeCustomizeScreen extends ConsumerWidget {
  const HomeCustomizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncCards = ref.watch(dashboardCardsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset to default',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: asyncCards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your dashboard.", onRetry: () => ref.invalidate(dashboardCardsProvider)),
        data: (cards) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(LifeSpace.s16, LifeSpace.s12, LifeSpace.s16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Today is always first and can't be hidden or reordered.",
                    style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
                  itemCount: cards.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final reordered = List<AppDashboardCard>.from(cards);
                    final moved = reordered.removeAt(oldIndex);
                    reordered.insert(newIndex, moved);
                    ref.read(dashboardCardRepositoryProvider).reorder(reordered);
                  },
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return LListTile(
                      key: ValueKey(card.id),
                      leading: const Icon(Icons.drag_indicator),
                      title: _cardTypeLabels[card.type] ?? card.type.name,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _cycleSize(ref, card),
                            child: Text(_sizeLabels[card.size]!),
                          ),
                          Switch(
                            value: card.visible,
                            onChanged: (visible) => ref.read(dashboardCardRepositoryProvider).setVisible(card, visible: visible),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _cycleSize(WidgetRef ref, AppDashboardCard card) {
    const order = [DashboardCardSize.small, DashboardCardSize.medium, DashboardCardSize.large];
    final next = order[(order.indexOf(card.size) + 1) % order.length];
    ref.read(dashboardCardRepositoryProvider).setSize(card, next);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await LConfirmDialog.show(
      context,
      title: 'Reset to default?',
      message: 'This discards your card order, visibility and sizes.',
      confirmLabel: 'Reset',
    );
    if (!confirmed) return;
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(dashboardCardRepositoryProvider).resetToDefault(userId);
  }
}
