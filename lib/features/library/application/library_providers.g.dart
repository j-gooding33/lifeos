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

@ProviderFor(collectionRepository)
const collectionRepositoryProvider = CollectionRepositoryProvider._();

final class CollectionRepositoryProvider
    extends
        $FunctionalProvider<
          CollectionRepository,
          CollectionRepository,
          CollectionRepository
        >
    with $Provider<CollectionRepository> {
  const CollectionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CollectionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollectionRepository create(Ref ref) {
    return collectionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionRepository>(value),
    );
  }
}

String _$collectionRepositoryHash() =>
    r'050946c07b42de2539095d4e7d3fef663efd2101';

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

@ProviderFor(collections)
const collectionsProvider = CollectionsProvider._();

final class CollectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppCollection>>,
          List<AppCollection>,
          Stream<List<AppCollection>>
        >
    with
        $FutureModifier<List<AppCollection>>,
        $StreamProvider<List<AppCollection>> {
  const CollectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppCollection>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppCollection>> create(Ref ref) {
    return collections(ref);
  }
}

String _$collectionsHash() => r'b5d145835354f9d012b2a4a6ae27a88d5cdba9cb';

@ProviderFor(collectionById)
const collectionByIdProvider = CollectionByIdFamily._();

final class CollectionByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppCollection?>,
          AppCollection?,
          Stream<AppCollection?>
        >
    with $FutureModifier<AppCollection?>, $StreamProvider<AppCollection?> {
  const CollectionByIdProvider._({
    required CollectionByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionByIdHash();

  @override
  String toString() {
    return r'collectionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppCollection?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppCollection?> create(Ref ref) {
    final argument = this.argument as String;
    return collectionById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionByIdHash() => r'772b60834d5091bdbbaea8e3be880df70c6c2e8c';

final class CollectionByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppCollection?>, String> {
  const CollectionByIdFamily._()
    : super(
        retry: null,
        name: r'collectionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionByIdProvider call(String id) =>
      CollectionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'collectionByIdProvider';
}

/// Joins a collection's membership list to full items in one query — a
/// collection can hold a mix of films, TV shows and books.

@ProviderFor(collectionItems)
const collectionItemsProvider = CollectionItemsFamily._();

/// Joins a collection's membership list to full items in one query — a
/// collection can hold a mix of films, TV shows and books.

final class CollectionItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppLibraryItem>>,
          List<AppLibraryItem>,
          Stream<List<AppLibraryItem>>
        >
    with
        $FutureModifier<List<AppLibraryItem>>,
        $StreamProvider<List<AppLibraryItem>> {
  /// Joins a collection's membership list to full items in one query — a
  /// collection can hold a mix of films, TV shows and books.
  const CollectionItemsProvider._({
    required CollectionItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionItemsHash();

  @override
  String toString() {
    return r'collectionItemsProvider'
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
    final argument = this.argument as String;
    return collectionItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemsHash() => r'39e23f75fd71e6b55d9ce43be7d065379150247d';

/// Joins a collection's membership list to full items in one query — a
/// collection can hold a mix of films, TV shows and books.

final class CollectionItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppLibraryItem>>, String> {
  const CollectionItemsFamily._()
    : super(
        retry: null,
        name: r'collectionItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Joins a collection's membership list to full items in one query — a
  /// collection can hold a mix of films, TV shows and books.

  CollectionItemsProvider call(String collectionId) =>
      CollectionItemsProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionItemsProvider';
}

@ProviderFor(collectionIdsContaining)
const collectionIdsContainingProvider = CollectionIdsContainingFamily._();

final class CollectionIdsContainingProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  const CollectionIdsContainingProvider._({
    required CollectionIdsContainingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionIdsContainingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionIdsContainingHash();

  @override
  String toString() {
    return r'collectionIdsContainingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    final argument = this.argument as String;
    return collectionIdsContaining(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionIdsContainingProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionIdsContainingHash() =>
    r'e8f61d44a305876ca98abbfbb7c9a7a21b4b7531';

final class CollectionIdsContainingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<String>>, String> {
  const CollectionIdsContainingFamily._()
    : super(
        retry: null,
        name: r'collectionIdsContainingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionIdsContainingProvider call(String libraryItemId) =>
      CollectionIdsContainingProvider._(argument: libraryItemId, from: this);

  @override
  String toString() => r'collectionIdsContainingProvider';
}

/// §16.4/§16.5's "Schedule this". `library/` needs `PlanRepository` for it,
/// but never `lib/features/plans/`'s own provider — that would be a
/// features-to-features import (rule 4). This wraps the same
/// `PlanDao`/database `plans/` own provider does, so a write through
/// either instance is visible to both.

@ProviderFor(libraryPlanRepository)
const libraryPlanRepositoryProvider = LibraryPlanRepositoryProvider._();

/// §16.4/§16.5's "Schedule this". `library/` needs `PlanRepository` for it,
/// but never `lib/features/plans/`'s own provider — that would be a
/// features-to-features import (rule 4). This wraps the same
/// `PlanDao`/database `plans/` own provider does, so a write through
/// either instance is visible to both.

final class LibraryPlanRepositoryProvider
    extends $FunctionalProvider<PlanRepository, PlanRepository, PlanRepository>
    with $Provider<PlanRepository> {
  /// §16.4/§16.5's "Schedule this". `library/` needs `PlanRepository` for it,
  /// but never `lib/features/plans/`'s own provider — that would be a
  /// features-to-features import (rule 4). This wraps the same
  /// `PlanDao`/database `plans/` own provider does, so a write through
  /// either instance is visible to both.
  const LibraryPlanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryPlanRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryPlanRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlanRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanRepository create(Ref ref) {
    return libraryPlanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanRepository>(value),
    );
  }
}

String _$libraryPlanRepositoryHash() =>
    r'5fa802b108b53d9211378cbf9f3c3e4659a8cd9d';

@ProviderFor(plansForMediaType)
const plansForMediaTypeProvider = PlansForMediaTypeFamily._();

final class PlansForMediaTypeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppPlan>>,
          List<AppPlan>,
          Stream<List<AppPlan>>
        >
    with $FutureModifier<List<AppPlan>>, $StreamProvider<List<AppPlan>> {
  const PlansForMediaTypeProvider._({
    required PlansForMediaTypeFamily super.from,
    required MediaType super.argument,
  }) : super(
         retry: null,
         name: r'plansForMediaTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$plansForMediaTypeHash();

  @override
  String toString() {
    return r'plansForMediaTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppPlan>> create(Ref ref) {
    final argument = this.argument as MediaType;
    return plansForMediaType(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlansForMediaTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$plansForMediaTypeHash() => r'18b2262d3b4f9d61ef8443f31f5e17e4f66413d2';

final class PlansForMediaTypeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppPlan>>, MediaType> {
  const PlansForMediaTypeFamily._()
    : super(
        retry: null,
        name: r'plansForMediaTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlansForMediaTypeProvider call(MediaType type) =>
      PlansForMediaTypeProvider._(argument: type, from: this);

  @override
  String toString() => r'plansForMediaTypeProvider';
}

/// TMDB's search results don't include season count — only `detail()` does
/// — so the TV show detail screen needs one extra round trip the first
/// time it's opened to know how many season rows to offer.

@ProviderFor(tvShowMetadata)
const tvShowMetadataProvider = TvShowMetadataFamily._();

/// TMDB's search results don't include season count — only `detail()` does
/// — so the TV show detail screen needs one extra round trip the first
/// time it's opened to know how many season rows to offer.

final class TvShowMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<MediaDetail, Failure>>,
          Result<MediaDetail, Failure>,
          FutureOr<Result<MediaDetail, Failure>>
        >
    with
        $FutureModifier<Result<MediaDetail, Failure>>,
        $FutureProvider<Result<MediaDetail, Failure>> {
  /// TMDB's search results don't include season count — only `detail()` does
  /// — so the TV show detail screen needs one extra round trip the first
  /// time it's opened to know how many season rows to offer.
  const TvShowMetadataProvider._({
    required TvShowMetadataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tvShowMetadataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tvShowMetadataHash();

  @override
  String toString() {
    return r'tvShowMetadataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<MediaDetail, Failure>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<MediaDetail, Failure>> create(Ref ref) {
    final argument = this.argument as String;
    return tvShowMetadata(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TvShowMetadataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tvShowMetadataHash() => r'21a5f15973d9fb7ef9a80c4bd476675f6ffaba62';

/// TMDB's search results don't include season count — only `detail()` does
/// — so the TV show detail screen needs one extra round trip the first
/// time it's opened to know how many season rows to offer.

final class TvShowMetadataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Result<MediaDetail, Failure>>,
          String
        > {
  const TvShowMetadataFamily._()
    : super(
        retry: null,
        name: r'tvShowMetadataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// TMDB's search results don't include season count — only `detail()` does
  /// — so the TV show detail screen needs one extra round trip the first
  /// time it's opened to know how many season rows to offer.

  TvShowMetadataProvider call(String externalId) =>
      TvShowMetadataProvider._(argument: externalId, from: this);

  @override
  String toString() => r'tvShowMetadataProvider';
}

/// Fetches a season's episode list from the provider and imports it
/// (`TvEpisodeRepository.importSeason` never overwrites existing
/// watched/rating/log state) the first time that season's screen opens.
/// Silently a no-op — not an error — for a manually-added show or an
/// unconfigured provider, matching §16.7's "missing data, not a crash".

@ProviderFor(seasonImport)
const seasonImportProvider = SeasonImportFamily._();

/// Fetches a season's episode list from the provider and imports it
/// (`TvEpisodeRepository.importSeason` never overwrites existing
/// watched/rating/log state) the first time that season's screen opens.
/// Silently a no-op — not an error — for a manually-added show or an
/// unconfigured provider, matching §16.7's "missing data, not a crash".

final class SeasonImportProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<void, Failure>>,
          Result<void, Failure>,
          FutureOr<Result<void, Failure>>
        >
    with
        $FutureModifier<Result<void, Failure>>,
        $FutureProvider<Result<void, Failure>> {
  /// Fetches a season's episode list from the provider and imports it
  /// (`TvEpisodeRepository.importSeason` never overwrites existing
  /// watched/rating/log state) the first time that season's screen opens.
  /// Silently a no-op — not an error — for a manually-added show or an
  /// unconfigured provider, matching §16.7's "missing data, not a crash".
  const SeasonImportProvider._({
    required SeasonImportFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'seasonImportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seasonImportHash();

  @override
  String toString() {
    return r'seasonImportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Result<void, Failure>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<void, Failure>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return seasonImport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonImportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seasonImportHash() => r'9dc5ac13e5f97a2238a70c7a60f15a599d0a407f';

/// Fetches a season's episode list from the provider and imports it
/// (`TvEpisodeRepository.importSeason` never overwrites existing
/// watched/rating/log state) the first time that season's screen opens.
/// Silently a no-op — not an error — for a manually-added show or an
/// unconfigured provider, matching §16.7's "missing data, not a crash".

final class SeasonImportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Result<void, Failure>>,
          (String, int)
        > {
  const SeasonImportFamily._()
    : super(
        retry: null,
        name: r'seasonImportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches a season's episode list from the provider and imports it
  /// (`TvEpisodeRepository.importSeason` never overwrites existing
  /// watched/rating/log state) the first time that season's screen opens.
  /// Silently a no-op — not an error — for a manually-added show or an
  /// unconfigured provider, matching §16.7's "missing data, not a crash".

  SeasonImportProvider call(String libraryItemId, int seasonNumber) =>
      SeasonImportProvider._(
        argument: (libraryItemId, seasonNumber),
        from: this,
      );

  @override
  String toString() => r'seasonImportProvider';
}
