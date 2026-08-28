// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkRepository)
const linkRepositoryProvider = LinkRepositoryProvider._();

final class LinkRepositoryProvider
    extends $FunctionalProvider<LinkRepository, LinkRepository, LinkRepository>
    with $Provider<LinkRepository> {
  const LinkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkRepositoryHash();

  @$internal
  @override
  $ProviderElement<LinkRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkRepository create(Ref ref) {
    return linkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkRepository>(value),
    );
  }
}

String _$linkRepositoryHash() => r'a1ac1172b4a3118376a8892b0eaca751f5658df6';

@ProviderFor(allLinks)
const allLinksProvider = AllLinksProvider._();

final class AllLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppLink>>,
          List<AppLink>,
          Stream<List<AppLink>>
        >
    with $FutureModifier<List<AppLink>>, $StreamProvider<List<AppLink>> {
  const AllLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allLinksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppLink>> create(Ref ref) {
    return allLinks(ref);
  }
}

String _$allLinksHash() => r'cbba6a0780b0a9932c03f2c7e67e192cf7e9d2cc';
