import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_dashboard_card.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/features/home/presentation/widgets/daily_stats_card.dart';
import 'package:life_os/features/home/presentation/widgets/focus_card.dart';
import 'package:life_os/features/home/presentation/widgets/goals_card.dart';
import 'package:life_os/features/home/presentation/widgets/habits_card.dart';
import 'package:life_os/features/home/presentation/widgets/journal_prompt_card.dart';
import 'package:life_os/features/home/presentation/widgets/plans_today_card.dart';
import 'package:life_os/features/home/presentation/widgets/projects_card.dart';
import 'package:life_os/features/home/presentation/widgets/recent_card.dart';
import 'package:life_os/features/home/presentation/widgets/spending_card.dart';
import 'package:life_os/features/home/presentation/widgets/upcoming_card.dart';
import 'package:life_os/routing/routes.dart';

/// §5. The one screen every user sees every day. `focus` is always first,
/// "cannot be hidden or moved" (§5.3) — rendered unconditionally rather
/// than as a `DashboardCard` row. Everything else comes from Settings →
/// Home dashboard's reorder/visibility (§5.4). `reading`, `filmNext`,
/// `study`, `activity` and `aiSuggestions` aren't built this pass — see
/// DECISIONS.md.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Evening';
  }

  Widget? _buildCard(DashboardCardType type, HomeSnapshot snapshot) {
    return switch (type) {
      DashboardCardType.plansToday => PlansTodayCard(snapshot: snapshot),
      DashboardCardType.habits => HabitsCard(snapshot: snapshot),
      DashboardCardType.upcoming => UpcomingCard(snapshot: snapshot),
      DashboardCardType.goals => GoalsCard(snapshot: snapshot),
      DashboardCardType.projects => ProjectsCard(snapshot: snapshot),
      DashboardCardType.recent => RecentCard(snapshot: snapshot),
      DashboardCardType.dailyStats => DailyStatsCard(snapshot: snapshot),
      DashboardCardType.journalPrompt => JournalPromptCard(snapshot: snapshot),
      DashboardCardType.spending => SpendingCard(snapshot: snapshot),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncSnapshot = ref.watch(homeSnapshotProvider);
    final asyncCards = ref.watch(dashboardCardsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(_greeting(), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push(Routes.search),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.more_horiz),
              tooltip: 'More',
              onPressed: () {
                final box = buttonContext.findRenderObject()! as RenderBox;
                final position = box.localToGlobal(box.size.center(Offset.zero));
                LMenu.showAt(
                  context: context,
                  position: position,
                  items: [
                    LMenuItem(label: 'Stats', icon: Icons.bar_chart_outlined, onTap: () => context.push(Routes.stats)),
                    LMenuItem(label: 'Journal', icon: Icons.book_outlined, onTap: () => context.push(Routes.journal)),
                    LMenuItem(label: 'Finance', icon: Icons.account_balance_wallet_outlined, onTap: () => context.push(Routes.finance)),
                    LMenuItem(label: 'School', icon: Icons.school_outlined, onTap: () => context.push(Routes.schoolDashboard)),
                  ],
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: asyncSnapshot.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(LifeSpace.s20),
          child: Column(
            children: [
              LLoadingShimmer(height: 120),
              SizedBox(height: LifeSpace.s12),
              LLoadingShimmer(height: 120),
            ],
          ),
        ),
        error: (error, stack) => LErrorState(
          message: "Couldn't load your day.",
          onRetry: () => ref.invalidate(homeSnapshotProvider),
        ),
        data: (snapshot) {
          final cards = asyncCards.value ?? const [];
          final visibleCards = cards.where((c) => c.visible).toList();
          return ListView(
            padding: const EdgeInsets.all(LifeSpace.s20),
            children: [
              FocusCard(snapshot: snapshot),
              for (final card in visibleCards)
                if (_buildCard(card.type, snapshot) case final widget?) ...[
                  const SizedBox(height: LifeSpace.cardGap),
                  widget,
                ],
            ],
          );
        },
      ),
    );
  }
}
