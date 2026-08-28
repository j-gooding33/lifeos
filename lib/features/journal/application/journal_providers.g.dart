// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(journalRepository)
const journalRepositoryProvider = JournalRepositoryProvider._();

final class JournalRepositoryProvider
    extends
        $FunctionalProvider<
          JournalRepository,
          JournalRepository,
          JournalRepository
        >
    with $Provider<JournalRepository> {
  const JournalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'journalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$journalRepositoryHash();

  @$internal
  @override
  $ProviderElement<JournalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  JournalRepository create(Ref ref) {
    return journalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalRepository>(value),
    );
  }
}

String _$journalRepositoryHash() => r'ac4d2e598d5343459cbc455f90e51d6ebeb744aa';

@ProviderFor(recentJournalEntries)
const recentJournalEntriesProvider = RecentJournalEntriesProvider._();

final class RecentJournalEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppJournalEntry>>,
          List<AppJournalEntry>,
          Stream<List<AppJournalEntry>>
        >
    with
        $FutureModifier<List<AppJournalEntry>>,
        $StreamProvider<List<AppJournalEntry>> {
  const RecentJournalEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentJournalEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentJournalEntriesHash();

  @$internal
  @override
  $StreamProviderElement<List<AppJournalEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppJournalEntry>> create(Ref ref) {
    return recentJournalEntries(ref);
  }
}

String _$recentJournalEntriesHash() =>
    r'55ce2a9a4ba1bc0e500f4ffc873de3a77ea277fb';

@ProviderFor(journalEntryByDate)
const journalEntryByDateProvider = JournalEntryByDateFamily._();

final class JournalEntryByDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppJournalEntry?>,
          AppJournalEntry?,
          Stream<AppJournalEntry?>
        >
    with $FutureModifier<AppJournalEntry?>, $StreamProvider<AppJournalEntry?> {
  const JournalEntryByDateProvider._({
    required JournalEntryByDateFamily super.from,
    required CivilDate super.argument,
  }) : super(
         retry: null,
         name: r'journalEntryByDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$journalEntryByDateHash();

  @override
  String toString() {
    return r'journalEntryByDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppJournalEntry?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppJournalEntry?> create(Ref ref) {
    final argument = this.argument as CivilDate;
    return journalEntryByDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is JournalEntryByDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$journalEntryByDateHash() =>
    r'8036d40317c3974e5ed918ac270fa56cf7d9fd6e';

final class JournalEntryByDateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppJournalEntry?>, CivilDate> {
  const JournalEntryByDateFamily._()
    : super(
        retry: null,
        name: r'journalEntryByDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  JournalEntryByDateProvider call(CivilDate date) =>
      JournalEntryByDateProvider._(argument: date, from: this);

  @override
  String toString() => r'journalEntryByDateProvider';
}
