import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';

const _titles = {MediaType.film: 'Film', MediaType.tv: 'TV', MediaType.book: 'Book'};
const _verbs = {MediaType.film: 'watched', MediaType.tv: 'watched', MediaType.book: 'read'};

/// §16.6. A lightweight per-media-type stats card computed directly from
/// `library_items` — a personal library is small enough that this doesn't
/// need §20.1's rollup-table architecture, which is for the much larger
/// general Stats tab spanning every domain's daily activity.
class LibraryStatsScreen extends ConsumerWidget {
  const LibraryStatsScreen({required this.mediaType, super.key});

  final MediaType mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final provider = libraryStatsProvider(mediaType);
    final asyncStats = ref.watch(provider);
    final verb = _verbs[mediaType]!;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: Text('${_titles[mediaType]} stats')),
      body: asyncStats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your stats.", onRetry: () => ref.invalidate(provider)),
        data: (stats) {
          if (stats.finishedThisYear == 0 && stats.averageRating == null) {
            return LEmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'Nothing to show yet',
              message: "Once you've $verb something, its stats show up here.",
            );
          }
          return ListView(
            padding: const EdgeInsets.all(LifeSpace.s16),
            children: [
              LCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    LStat(value: '${stats.finishedThisYear}', caption: '${verb.toUpperCase()} THIS YEAR'),
                    LStat(value: '${stats.finishedThisMonth}', caption: 'THIS MONTH'),
                    LStat(
                      value: stats.averageRating == null ? '—' : stats.averageRating!.toStringAsFixed(1),
                      caption: 'AVG RATING',
                    ),
                  ],
                ),
              ),
              if (stats.topGenre != null) ...[
                const SizedBox(height: LifeSpace.cardGap),
                LCard(
                  child: Row(
                    children: [
                      Icon(Icons.local_offer_outlined, size: 18, color: colors.neutrals.ink2),
                      const SizedBox(width: LifeSpace.s8),
                      Text(
                        'Most common genre: ${stats.topGenre}',
                        style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
                      ),
                    ],
                  ),
                ),
              ],
              if (stats.totalRuntimeMinutes != null && stats.totalRuntimeMinutes! > 0) ...[
                const SizedBox(height: LifeSpace.cardGap),
                LCard(
                  child: Row(
                    children: [
                      Icon(Icons.schedule_outlined, size: 18, color: colors.neutrals.ink2),
                      const SizedBox(width: LifeSpace.s8),
                      Text(
                        "You've watched ${(stats.totalRuntimeMinutes! / 60).round()} hours this year",
                        style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: LifeSpace.cardGap),
              LCard(child: _RatingDistribution(distribution: stats.ratingDistribution)),
            ],
          );
        },
      ),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution({required this.distribution});

  static const _maxBarHeight = 48.0;

  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxCount = distribution.values.fold(0, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating distribution', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
        const SizedBox(height: LifeSpace.s12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var star = 1; star <= 5; star++) ...[
              if (star > 1) const SizedBox(width: LifeSpace.s8),
              Expanded(child: _bar(context, star, distribution[star] ?? 0, maxCount)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _bar(BuildContext context, int star, int count, int maxCount) {
    final colors = context.colors;
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    final barHeight = count == 0 ? 2.0 : (fraction * _maxBarHeight).clamp(4.0, _maxBarHeight);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
        const SizedBox(height: LifeSpace.s4),
        Container(
          height: barHeight,
          decoration: BoxDecoration(color: colors.accent.base, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: LifeSpace.s4),
        Text('$star★', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3)),
      ],
    );
  }
}
