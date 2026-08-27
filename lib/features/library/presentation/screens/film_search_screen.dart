import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/tmdb_metadata_provider.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/features/library/presentation/widgets/mark_watched_sheet.dart';
import 'package:life_os/features/library/presentation/widgets/rate_dialog.dart';
import 'package:life_os/routing/routes.dart';

/// §16.4 Search / M8 Part 3. Debounced 350ms. If TMDB isn't configured
/// (§16.7), shows an honest configuration message with "Add without
/// searching" rather than pretending to search.
class FilmSearchScreen extends ConsumerStatefulWidget {
  const FilmSearchScreen({super.key});

  @override
  ConsumerState<FilmSearchScreen> createState() => _FilmSearchScreenState();
}

class _FilmSearchScreenState extends ConsumerState<FilmSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  AsyncValue<List<MediaSearchResult>> _results = const AsyncValue.data([]);
  var _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    setState(() => _query = query);
    if (query.trim().isEmpty) {
      setState(() => _results = const AsyncValue.data([]));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _results = const AsyncValue.loading());
    final result = await ref.read(tmdbMetadataProviderProvider).search(query, type: MediaType.film);
    if (!mounted) return;
    setState(() {
      _results = result.when(ok: AsyncValue.data, err: (f) => AsyncValue.error(f, StackTrace.current));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: LTextField(
          controller: _controller,
          placeholder: 'Search films',
          autofocus: true,
          onChanged: _onChanged,
        ),
      ),
      body: !isTmdbConfigured ? _buildUnconfigured(context) : _buildResults(context),
    );
  }

  Widget _buildUnconfigured(BuildContext context) {
    return LEmptyState(
      icon: Icons.search_off_outlined,
      title: 'Film search needs configuring',
      message: "A search API key hasn't been set up yet, but you can still add a film by hand.",
      actionLabel: 'Add without searching',
      onAction: () => _addManually(context),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_query.trim().isEmpty) {
      return const LEmptyState(icon: Icons.movie_outlined, title: 'Search for a film', message: 'Try a title.');
    }
    return _results.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(LifeSpace.s16),
        child: Column(children: [LLoadingShimmer(height: 120), SizedBox(height: LifeSpace.s12), LLoadingShimmer(height: 120)]),
      ),
      error: (error, stack) => LErrorState(message: "Couldn't search right now.", onRetry: () => _search(_query)),
      data: (results) {
        if (results.isEmpty) {
          return LEmptyState(
            icon: Icons.movie_outlined,
            title: 'No films found',
            message: 'Try a different search, or add "$_query" by hand.',
            actionLabel: 'Add without searching',
            onAction: () => _addManually(context, title: _query),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(LifeSpace.s16),
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s16),
          itemBuilder: (context, index) => _ResultCard(result: results[index]),
        );
      },
    );
  }

  Future<void> _addManually(BuildContext context, {String? title}) async {
    final userId = await ref.read(currentUserIdProvider.future);
    final result = await ref
        .read(libraryItemRepositoryProvider)
        .addManually(userId: userId, type: MediaType.film, title: title ?? _query);
    if (!context.mounted) return;
    result.when(
      ok: (item) => context.push(Routes.libraryFilmDetail.replaceFirst(':id', item.id)),
      err: (failure) => LToast.show(context, failure.message),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.result});

  final MediaSearchResult result;

  Future<String> _ensureAdded(WidgetRef ref) async {
    final userId = await ref.read(currentUserIdProvider.future);
    final added = await ref
        .read(libraryItemRepositoryProvider)
        .addFromSearchResult(userId: userId, type: MediaType.film, providerId: 'tmdb', result: result);
    return added.when(ok: (item) => item.id, err: (f) => throw StateError(f.message));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return InkWell(
      onTap: () async {
        final id = await _ensureAdded(ref);
        if (context.mounted) unawaited(context.push(Routes.libraryFilmDetail.replaceFirst(':id', id)));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LPosterTile(width: 80, imageProvider: posterImageFor(ref, MediaType.film, result.posterPath)),
          const SizedBox(width: LifeSpace.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.title, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
                if (result.year != null)
                  Text('${result.year}', style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2)),
                if (result.genres.isNotEmpty)
                  Text(
                    result.genres.join(' · '),
                    style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
                  ),
                const SizedBox(height: LifeSpace.s8),
                Wrap(
                  spacing: LifeSpace.s8,
                  runSpacing: LifeSpace.s8,
                  children: [
                    LChip(
                      label: '+ Watchlist',
                      icon: Icons.bookmark_add_outlined,
                      onTap: () async {
                        await _ensureAdded(ref);
                        if (context.mounted) LToast.show(context, 'Added to your watchlist');
                      },
                    ),
                    LChip(
                      label: 'Watched',
                      icon: Icons.check_circle_outline,
                      onTap: () async {
                        final id = await _ensureAdded(ref);
                        final item = await ref.read(libraryItemByIdProvider(id).future);
                        if (context.mounted && item != null) await MarkWatchedSheet.show(context, item);
                      },
                    ),
                    LChip(
                      label: '★ Rate',
                      onTap: () async {
                        final id = await _ensureAdded(ref);
                        final item = await ref.read(libraryItemByIdProvider(id).future);
                        if (context.mounted && item != null) await RateDialog.show(context, ref, item);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
