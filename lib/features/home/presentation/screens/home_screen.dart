import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/features/home/presentation/widgets/focus_card.dart';
import 'package:life_os/features/home/presentation/widgets/recent_card.dart';
import 'package:life_os/features/home/presentation/widgets/upcoming_card.dart';
import 'package:life_os/routing/routes.dart';

/// §5. The one screen every user sees every day. Only `focus`, `upcoming`
/// and `recent` exist yet (M5) — the rest of the §5.3 card catalogue
/// arrives with the features that feed it (Plans, Habits, Goals, ...).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncSnapshot = ref.watch(homeSnapshotProvider);

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
        data: (snapshot) => ListView(
          padding: const EdgeInsets.all(LifeSpace.s20),
          children: [
            FocusCard(snapshot: snapshot),
            const SizedBox(height: LifeSpace.cardGap),
            UpcomingCard(snapshot: snapshot),
            const SizedBox(height: LifeSpace.cardGap),
            RecentCard(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}
