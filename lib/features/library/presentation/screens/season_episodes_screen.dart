import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';

/// Per-episode tracking (M8 Parts 12-14, un-postponed from M1). Episode
/// ratings run 1-6★ — the 6th star is a distinct "personal favourite" tier
/// (`LStarRating`'s own `maxRating: 6` mode), never averaged into the
/// show's own 1-5★ rating.
class SeasonEpisodesScreen extends ConsumerWidget {
  const SeasonEpisodesScreen({required this.showId, required this.seasonNumber, super.key});

  final String showId;
  final int seasonNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // Triggers the import (a no-op once episodes already exist locally);
    // the actual list below reads from the local DB stream regardless of
    // whether this is still in flight, so a slow/failed provider call
    // never blocks episodes the user has already tracked from showing.
    ref.watch(seasonImportProvider(showId, seasonNumber));

    final episodesProvider = episodesForSeasonProvider(showId, seasonNumber);
    final asyncEpisodes = ref.watch(episodesProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: Text('Season $seasonNumber')),
      body: asyncEpisodes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            LErrorState(message: "Couldn't load episodes.", onRetry: () => ref.invalidate(episodesProvider)),
        data: (episodes) {
          if (episodes.isEmpty) {
            return const LEmptyState(
              icon: Icons.tv_outlined,
              title: 'No episodes yet',
              message: "This season's episode list isn't available yet.",
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(LifeSpace.s16),
            itemCount: episodes.length,
            separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s12),
            itemBuilder: (context, index) => _EpisodeRow(episode: episodes[index]),
          );
        },
      ),
    );
  }
}

class _EpisodeRow extends ConsumerWidget {
  const _EpisodeRow({required this.episode});

  final AppTvEpisode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final repository = ref.read(tvEpisodeRepositoryProvider);

    return Container(
      padding: const EdgeInsets.all(LifeSpace.s12),
      decoration: BoxDecoration(
        color: colors.neutrals.surface,
        borderRadius: BorderRadius.circular(LifeRadius.card),
        border: Border.all(color: colors.neutrals.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LCheckCircle(
            checked: episode.isWatched,
            semanticLabel: episode.isWatched ? 'Mark not watched' : 'Mark watched',
            onChanged: (checked) {
              if (checked) {
                repository.markWatched(episode.id, watchedDate: DateTime.now());
              } else {
                repository.markUnwatched(episode.id);
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E${episode.episodeNumber} · ${episode.title ?? 'Untitled'}',
                  style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink),
                ),
                if (episode.airDate != null)
                  Text(episode.airDate!.toIso(), style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3)),
                const SizedBox(height: LifeSpace.s8),
                LStarRating(
                  rating: episode.rating,
                  maxRating: 6,
                  size: 18,
                  onChanged: (value) => repository.setRating(episode.id, value),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Log',
            onPressed: () => _editLog(context, ref, episode),
          ),
        ],
      ),
    );
  }

  Future<void> _editLog(BuildContext context, WidgetRef ref, AppTvEpisode episode) async {
    final controller = TextEditingController(text: episode.log ?? '');
    final colors = context.colors;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.neutrals.surface,
        title: const Text('Episode log'),
        content: TextField(controller: controller, maxLines: 4, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          LButton(label: 'Save', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (saved ?? false) {
      final text = controller.text.trim();
      await ref.read(tvEpisodeRepositoryProvider).setLog(episode.id, text.isEmpty ? null : text);
    }
  }
}
