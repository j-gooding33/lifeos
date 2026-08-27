// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(noteRepository)
const noteRepositoryProvider = NoteRepositoryProvider._();

final class NoteRepositoryProvider
    extends $FunctionalProvider<NoteRepository, NoteRepository, NoteRepository>
    with $Provider<NoteRepository> {
  const NoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteRepository create(Ref ref) {
    return noteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRepository>(value),
    );
  }
}

String _$noteRepositoryHash() => r'180799018964e231dd122f231c47d4523fcd6ac7';

@ProviderFor(allNotes)
const allNotesProvider = AllNotesProvider._();

final class AllNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNote>>,
          List<AppNote>,
          Stream<List<AppNote>>
        >
    with $FutureModifier<List<AppNote>>, $StreamProvider<List<AppNote>> {
  const AllNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allNotesHash();

  @$internal
  @override
  $StreamProviderElement<List<AppNote>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNote>> create(Ref ref) {
    return allNotes(ref);
  }
}

String _$allNotesHash() => r'b94b89f78f642a828448703b15812ff71a9bcb71';

@ProviderFor(noteById)
const noteByIdProvider = NoteByIdFamily._();

final class NoteByIdProvider
    extends
        $FunctionalProvider<AsyncValue<AppNote?>, AppNote?, Stream<AppNote?>>
    with $FutureModifier<AppNote?>, $StreamProvider<AppNote?> {
  const NoteByIdProvider._({
    required NoteByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'noteByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteByIdHash();

  @override
  String toString() {
    return r'noteByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppNote?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppNote?> create(Ref ref) {
    final argument = this.argument as String;
    return noteById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteByIdHash() => r'562d4bb6a70ae3f1585d49a3284d2e3c7ad216bb';

final class NoteByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppNote?>, String> {
  const NoteByIdFamily._()
    : super(
        retry: null,
        name: r'noteByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NoteByIdProvider call(String noteId) =>
      NoteByIdProvider._(argument: noteId, from: this);

  @override
  String toString() => r'noteByIdProvider';
}
