// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(libraryItemRepository)
const libraryItemRepositoryProvider = LibraryItemRepositoryProvider._();

final class LibraryItemRepositoryProvider
    extends
        $FunctionalProvider<
          LibraryItemRepository,
          LibraryItemRepository,
          LibraryItemRepository
        >
    with $Provider<LibraryItemRepository> {
  const LibraryItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryItemRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<LibraryItemRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LibraryItemRepository create(Ref ref) {
    return libraryItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LibraryItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LibraryItemRepository>(value),
    );
  }
}

String _$libraryItemRepositoryHash() =>
    r'603c0ab9abc4795a8fba11ce2a387f5f66d3b4fe';

@ProviderFor(tvEpisodeRepository)
const tvEpisodeRepositoryProvider = TvEpisodeRepositoryProvider._();

final class TvEpisodeRepositoryProvider
    extends
        $FunctionalProvider<
          TvEpisodeRepository,
          TvEpisodeRepository,
          TvEpisodeRepository
        >
    with $Provider<TvEpisodeRepository> {
  const TvEpisodeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tvEpisodeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tvEpisodeRepositoryHash();

  @$internal
  @override
  $ProviderElement<TvEpisodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TvEpisodeRepository create(Ref ref) {
    return tvEpisodeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TvEpisodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TvEpisodeRepository>(value),
    );
  }
}

String _$tvEpisodeRepositoryHash() =>
    r'74ed0eb26fd13abc1fc298beae54b61d91a3db46';

@ProviderFor(topListRepository)
const topListRepositoryProvider = TopListRepositoryProvider._();

final class TopListRepositoryProvider
    extends
        $FunctionalProvider<
          TopListRepository,
          TopListRepository,
          TopListRepository
        >
    with $Provider<TopListRepository> {
  const TopListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topListRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topListRepositoryHash();

  @$internal
  @override
  $ProviderElement<TopListRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TopListRepository create(Ref ref) {
    return topListRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TopListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TopListRepository>(value),
    );
  }
}

String _$topListRepositoryHash() => r'5ba313b42b809067caef7c0a939a4d9915d30328';

/// §16.2: films and TV both use TMDB; books use Open Library. One provider
/// instance each, kept alive for the app's lifetime.

@ProviderFor(tmdbMetadataProvider)
const tmdbMetadataProviderProvider = TmdbMetadataProviderProvider._();

/// §16.2: films and TV both use TMDB; books use Open Library. One provider
/// instance each, kept alive for the app's lifetime.

final class TmdbMetadataProviderProvider
    extends
        $FunctionalProvider<
          TmdbMetadataProvider,
          TmdbMetadataProvider,
          TmdbMetadataProvider
        >
    with $Provider<TmdbMetadataProvider> {
  /// §16.2: films and TV both use TMDB; books use Open Library. One provider
  /// instance each, kept alive for the app's lifetime.
  const TmdbMetadataProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tmdbMetadataProviderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tmdbMetadataProviderHash();

  @$internal
  @override
  $ProviderElement<TmdbMetadataProvider> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TmdbMetadataProvider create(Ref ref) {
    return tmdbMetadataProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TmdbMetadataProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TmdbMetadataProvider>(value),
    );
  }
}

String _$tmdbMetadataProviderHash() =>
    r'220048294e8f90d2d7e8f7ca9eaa5b1a1dc15184';

@ProviderFor(openLibraryProvider)
const openLibraryProviderProvider = OpenLibraryProviderProvider._();

final class OpenLibraryProviderProvider
    extends
        $FunctionalProvider<
          OpenLibraryProvider,
          OpenLibraryProvider,
          OpenLibraryProvider
        >
    with $Provider<OpenLibraryProvider> {
  const OpenLibraryProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openLibraryProviderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openLibraryProviderHash();

  @$internal
  @override
  $ProviderElement<OpenLibraryProvider> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenLibraryProvider create(Ref ref) {
    return openLibraryProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenLibraryProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenLibraryProvider>(value),
    );
  }
}

String _$openLibraryProviderHash() =>
    r'3f082a6b07d6c43371b2148f66f27fc5bb3c2e3f';

@ProviderFor(libraryByStatus)
const libraryByStatusProvider = LibraryByStatusFamily._();

final class LibraryByStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppLibraryItem>>,
          List<AppLibraryItem>,
          Stream<List<AppLibraryItem>>
        >
    with
        $FutureModifier<List<AppLibraryItem>>,
        $StreamProvider<List<AppLibraryItem>> {
  const LibraryByStatusProvider._({
    required LibraryByStatusFamily super.from,
    required (MediaType, LibraryItemStatus) super.argument,
  }) : super(
         retry: null,
         name: r'libraryByStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$libraryByStatusHash();

  @override
  String toString() {
    return r'libraryByStatusProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppLibraryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppLibraryItem>> create(Ref ref) {
    final argument = this.argument as (MediaType, LibraryItemStatus);
    return libraryByStatus(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryByStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$libraryByStatusHash() => r'501132e70789313088c408691ce24afef0eab97a';

final class LibraryByStatusFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AppLibraryItem>>,
          (MediaType, LibraryItemStatus)
        > {
  const LibraryByStatusFamily._()
    : super(
        retry: null,
        name: r'libraryByStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LibraryByStatusProvider call(MediaType type, LibraryItemStatus status) =>
      LibraryByStatusProvider._(argument: (type, status), from: this);

  @override
  String toString() => r'libraryByStatusProvider';
}

@ProviderFor(libraryAll)
const libraryAllProvider = LibraryAllFamily._();

final class LibraryAllProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppLibraryItem>>,
          List<AppLibraryItem>,
          Stream<List<AppLibraryItem>>
        >
    with
        $FutureModifier<List<AppLibraryItem>>,
        $StreamProvider<List<AppLibraryItem>> {
  const LibraryAllProvider._({
    required LibraryAllFamily super.from,
    required MediaType super.argument,
  }) : super(
         retry: null,
         name: r'libraryAllProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$libraryAllHash();

  @override
  String toString() {
    return r'libraryAllProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppLibraryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppLibraryItem>> create(Ref ref) {
    final argument = this.argument as MediaType;
    return libraryAll(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryAllProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$libraryAllHash() => r'6976c584b5af7ba0b4ec548c46eadde8ac7703d3';

final class LibraryAllFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppLibraryItem>>, MediaType> {
  const LibraryAllFamily._()
    : super(
        retry: null,
        name: r'libraryAllProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LibraryAllProvider call(MediaType type) =>
      LibraryAllProvider._(argument: type, from: this);

  @override
  String toString() => r'libraryAllProvider';
}

@ProviderFor(libraryFavourites)
const libraryFavouritesProvider = LibraryFavouritesFamily._();

final class LibraryFavouritesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppLibraryItem>>,
          List<AppLibraryItem>,
          Stream<List<AppLibraryItem>>
        >
    with
        $FutureModifier<List<AppLibraryItem>>,
        $StreamProvider<List<AppLibraryItem>> {
  const LibraryFavouritesProvider._({
    required LibraryFavouritesFamily super.from,
    required MediaType super.argument,
  }) : super(
         retry: null,
         name: r'libraryFavouritesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$libraryFavouritesHash();

  @override
  String toString() {
    return r'libraryFavouritesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppLibraryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppLibraryItem>> create(Ref ref) {
    final argument = this.argument as MediaType;
    return libraryFavourites(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryFavouritesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$libraryFavouritesHash() => r'cb7430d69a25e28d239d968481be76af5555f719';

final class LibraryFavouritesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppLibraryItem>>, MediaType> {
  const LibraryFavouritesFamily._()
    : super(
        retry: null,
        name: r'libraryFavouritesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LibraryFavouritesProvider call(MediaType type) =>
      LibraryFavouritesProvider._(argument: type, from: this);

  @override
  String toString() => r'libraryFavouritesProvider';
}

@ProviderFor(libraryRated)
const libraryRatedProvider = LibraryRatedFamily._();

final class LibraryRatedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppLibraryItem>>,
          List<AppLibraryItem>,
          Stream<List<AppLibraryItem>>
        >
    with
        $FutureModifier<List<AppLibraryItem>>,
        $StreamProvider<List<AppLibraryItem>> {
  const LibraryRatedProvider._({
    required LibraryRatedFamily super.from,
    required MediaType super.argument,
  }) : super(
         retry: null,
         name: r'libraryRatedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$libraryRatedHash();

  @override
  String toString() {
    return r'libraryRatedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppLibraryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppLibraryItem>> create(Ref ref) {
    final argument = this.argument as MediaType;
    return libraryRated(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryRatedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$libraryRatedHash() => r'ba7cc6745200699e1859c30a03fcb9d3aae69d44';

final class LibraryRatedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppLibraryItem>>, MediaType> {
  const LibraryRatedFamily._()
    : super(
        retry: null,
        name: r'libraryRatedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LibraryRatedProvider call(MediaType type) =>
      LibraryRatedProvider._(argument: type, from: this);

  @override
  String toString() => r'libraryRatedProvider';
}

@ProviderFor(libraryItemById)
const libraryItemByIdProvider = LibraryItemByIdFamily._();

final class LibraryItemByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppLibraryItem?>,
          AppLibraryItem?,
          Stream<AppLibraryItem?>
        >
    with $FutureModifier<AppLibraryItem?>, $StreamProvider<AppLibraryItem?> {
  const LibraryItemByIdProvider._({
    required LibraryItemByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'libraryItemByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$libraryItemByIdHash();

  @override
  String toString() {
    return r'libraryItemByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppLibraryItem?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppLibraryItem?> create(Ref ref) {
    final argument = this.argument as String;
    return libraryItemById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryItemByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$libraryItemByIdHash() => r'0bb73d586dbbae2ee37ba86d9076329a7f4f2fe7';

final class LibraryItemByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppLibraryItem?>, String> {
  const LibraryItemByIdFamily._()
    : super(
        retry: null,
        name: r'libraryItemByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LibraryItemByIdProvider call(String id) =>
      LibraryItemByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'libraryItemByIdProvider';
}

@ProviderFor(episodesForShow)
const episodesForShowProvider = EpisodesForShowFamily._();

final class EpisodesForShowProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTvEpisode>>,
          List<AppTvEpisode>,
          Stream<List<AppTvEpisode>>
        >
    with
        $FutureModifier<List<AppTvEpisode>>,
        $StreamProvider<List<AppTvEpisode>> {
  const EpisodesForShowProvider._({
    required EpisodesForShowFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'episodesForShowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodesForShowHash();

  @override
  String toString() {
    return r'episodesForShowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppTvEpisode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTvEpisode>> create(Ref ref) {
    final argument = this.argument as String;
    return episodesForShow(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodesForShowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodesForShowHash() => r'41abf21590a6bf60256ed853212bb7ba683eb2b4';

final class EpisodesForShowFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppTvEpisode>>, String> {
  const EpisodesForShowFamily._()
    : super(
        retry: null,
        name: r'episodesForShowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpisodesForShowProvider call(String libraryItemId) =>
      EpisodesForShowProvider._(argument: libraryItemId, from: this);

  @override
  String toString() => r'episodesForShowProvider';
}

@ProviderFor(episodesForSeason)
const episodesForSeasonProvider = EpisodesForSeasonFamily._();

final class EpisodesForSeasonProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTvEpisode>>,
          List<AppTvEpisode>,
          Stream<List<AppTvEpisode>>
        >
    with
        $FutureModifier<List<AppTvEpisode>>,
        $StreamProvider<List<AppTvEpisode>> {
  const EpisodesForSeasonProvider._({
    required EpisodesForSeasonFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'episodesForSeasonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodesForSeasonHash();

  @override
  String toString() {
    return r'episodesForSeasonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppTvEpisode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTvEpisode>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return episodesForSeason(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodesForSeasonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodesForSeasonHash() => r'779fd02062e59fe7716d407364b0e99f6aec3c02';

final class EpisodesForSeasonFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppTvEpisode>>, (String, int)> {
  const EpisodesForSeasonFamily._()
    : super(
        retry: null,
        name: r'episodesForSeasonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpisodesForSeasonProvider call(String libraryItemId, int seasonNumber) =>
      EpisodesForSeasonProvider._(
        argument: (libraryItemId, seasonNumber),
        from: this,
      );

  @override
  String toString() => r'episodesForSeasonProvider';
}

@ProviderFor(ratedEpisodes)
const ratedEpisodesProvider = RatedEpisodesProvider._();

final class RatedEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTvEpisode>>,
          List<AppTvEpisode>,
          Stream<List<AppTvEpisode>>
        >
    with
        $FutureModifier<List<AppTvEpisode>>,
        $StreamProvider<List<AppTvEpisode>> {
  const RatedEpisodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ratedEpisodesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ratedEpisodesHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTvEpisode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTvEpisode>> create(Ref ref) {
    return ratedEpisodes(ref);
  }
}

String _$ratedEpisodesHash() => r'abfcbbb0b659988beb9434ea1cc57cf13f4d3fcd';

@ProviderFor(topList)
const topListProvider = TopListFamily._();

final class TopListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TopListEntry>>,
          List<TopListEntry>,
          Stream<List<TopListEntry>>
        >
    with
        $FutureModifier<List<TopListEntry>>,
        $StreamProvider<List<TopListEntry>> {
  const TopListProvider._({
    required TopListFamily super.from,
    required MediaType super.argument,
  }) : super(
         retry: null,
         name: r'topListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topListHash();

  @override
  String toString() {
    return r'topListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TopListEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TopListEntry>> create(Ref ref) {
    final argument = this.argument as MediaType;
    return topList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topListHash() => r'3202ee5e1538328af91326cb25afd89187ee0581';

final class TopListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TopListEntry>>, MediaType> {
  const TopListFamily._()
    : super(
        retry: null,
        name: r'topListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TopListProvider call(MediaType type) =>
      TopListProvider._(argument: type, from: this);

  @override
  String toString() => r'topListProvider';
}
