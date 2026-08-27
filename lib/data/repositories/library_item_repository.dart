import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:uuid/uuid.dart';

/// §16, M8 Parts 2-9/18-25. Films, TV shows and books all go through this
/// one repository over `library_items` — see the class doc comment on
/// `AppLibraryItem` and the M8 `DECISIONS.md` entry for why that's one
/// polymorphic table rather than three.
class LibraryItemRepository {
  LibraryItemRepository(this._dao);

  final LibraryItemDao _dao;

  Stream<List<AppLibraryItem>> watchByStatus(
    String userId,
    LibraryMediaType type,
    LibraryItemStatus status,
  ) {
    return _dao
        .watchByStatus(userId, type.name, status.name)
        .map(_toDomainList);
  }

  Stream<List<AppLibraryItem>> watchAll(String userId, LibraryMediaType type) {
    return _dao.watchAllForType(userId, type.name).map(_toDomainList);
  }

  Stream<List<AppLibraryItem>> watchFavourites(
    String userId,
    LibraryMediaType type,
  ) {
    return _dao.watchFavourites(userId, type.name).map(_toDomainList);
  }

  Stream<List<AppLibraryItem>> watchRated(
    String userId,
    LibraryMediaType type,
  ) {
    return _dao.watchRated(userId, type.name).map(_toDomainList);
  }

  Stream<AppLibraryItem?> watchById(String id) {
    return _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));
  }

  /// §16.7: adding an already-saved item just returns the existing row
  /// rather than creating a duplicate.
  Future<Result<AppLibraryItem, Failure>> addFromSearchResult({
    required String userId,
    required LibraryMediaType type,
    required String providerId,
    required MediaSearchResult result,
  }) async {
    try {
      final existing = await _dao.getByExternalId(
        userId,
        providerId,
        result.externalId,
      );
      if (existing != null) return Ok(_toDomain(existing));

      final item = AppLibraryItem(
        id: const Uuid().v4(),
        userId: userId,
        mediaType: type,
        title: result.title,
        providerId: providerId,
        externalId: result.externalId,
        year: result.year,
        posterPath: result.posterPath,
        overview: result.overview,
        genres: result.genres,
        creators: result.author == null ? const [] : [result.author!],
        runtimeMinutes: result.runtimeMinutes,
      );
      await _save(item);
      return Ok(item);
    } on Object catch (e) {
      return Err(DatabaseFailure('addFromSearchResult failed: $e'));
    }
  }

  /// §16.7 "manual add ('Add without searching') remains available" — for
  /// when a provider is unconfigured or a title genuinely isn't listed.
  Future<Result<AppLibraryItem, Failure>> addManually({
    required String userId,
    required LibraryMediaType type,
    required String title,
    int? year,
  }) async {
    try {
      final item = AppLibraryItem(
        id: const Uuid().v4(),
        userId: userId,
        mediaType: type,
        title: title,
        year: year,
      );
      await _save(item);
      return Ok(item);
    } on Object catch (e) {
      return Err(DatabaseFailure('addManually failed: $e'));
    }
  }

  Future<Result<void, Failure>> setStatus(
    String id, {
    required LibraryItemStatus status,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return Err(NotFoundFailure('Library item $id not found'));
      }
      final item = _toDomain(
        row,
      ).copyWith(status: status, startedAt: startedAt, finishedAt: finishedAt);
      await _save(item);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setStatus failed: $e'));
    }
  }

  /// Parts 5/20-22: marking watched/finished, an optional rating, and the
  /// date can all be set together or separately — rating before watching
  /// and watching without rating are both allowed (§43 edge cases) because
  /// this and [setRating] never require each other.
  Future<Result<void, Failure>> markWatched(
    String id, {
    required DateTime watchedDate,
    double? rating,
  }) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return Err(NotFoundFailure('Library item $id not found'));
      }
      final item = _toDomain(row).copyWith(
        status: LibraryItemStatus.done,
        finishedAt: watchedDate,
        rating: rating,
      );
      await _save(item);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('markWatched failed: $e'));
    }
  }

  Future<Result<void, Failure>> setRating(String id, double? rating) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return Err(NotFoundFailure('Library item $id not found'));
      }
      final item = _toDomain(row)
          .copyWith(rating: rating, clearRating: rating == null);
      await _save(item);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setRating failed: $e'));
    }
  }

  /// The personal log (Parts 5, 22) — editable at any time.
  Future<Result<void, Failure>> setNotes(String id, String? notes) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return Err(NotFoundFailure('Library item $id not found'));
      }
      final item = _toDomain(row)
          .copyWith(notes: notes, clearNotes: notes == null);
      await _save(item);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setNotes failed: $e'));
    }
  }

  Future<Result<void, Failure>> setFavourite(
    String id, {
    required bool isFavourite,
  }) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return Err(NotFoundFailure('Library item $id not found'));
      }
      final item = _toDomain(row).copyWith(isFavourite: isFavourite);
      await _save(item);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setFavourite failed: $e'));
    }
  }

  Future<Result<void, Failure>> remove(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('remove failed: $e'));
    }
  }

  Future<void> _save(AppLibraryItem item) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.LibraryItemsCompanion(
        id: Value(item.id),
        userId: Value(item.userId),
        mediaType: Value(item.mediaType.name),
        title: Value(item.title),
        sortTitle: Value(item.sortTitle ?? item.title.toLowerCase()),
        providerId: Value(item.providerId),
        externalId: Value(item.externalId),
        year: Value(item.year),
        posterPath: Value(item.posterPath),
        backdropPath: Value(item.backdropPath),
        overview: Value(item.overview),
        runtimeMinutes: Value(item.runtimeMinutes),
        genres: Value(jsonEncode(item.genres)),
        creators: Value(jsonEncode(item.creators)),
        status: Value(item.status.name),
        rating: Value(item.rating),
        isFavourite: Value(item.isFavourite),
        notes: Value(item.notes),
        progressValue: Value(item.progressValue),
        progressUnit: Value(item.progressUnit),
        addedAt: Value(item.addedAt.millisecondsSinceEpoch),
        startedAt: Value(item.startedAt?.millisecondsSinceEpoch),
        finishedAt: Value(item.finishedAt?.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppLibraryItem> _toDomainList(List<db.LibraryItem> rows) =>
      rows.map(_toDomain).toList();

  AppLibraryItem _toDomain(db.LibraryItem row) {
    return AppLibraryItem(
      id: row.id,
      userId: row.userId,
      mediaType: LibraryMediaType.values.byName(row.mediaType),
      title: row.title,
      sortTitle: row.sortTitle,
      providerId: row.providerId,
      externalId: row.externalId,
      year: row.year,
      posterPath: row.posterPath,
      backdropPath: row.backdropPath,
      overview: row.overview,
      runtimeMinutes: row.runtimeMinutes,
      genres: _decodeStringList(row.genres),
      creators: _decodeStringList(row.creators),
      status: LibraryItemStatus.values.byName(row.status),
      rating: row.rating,
      isFavourite: row.isFavourite,
      notes: row.notes,
      progressValue: row.progressValue,
      progressUnit: row.progressUnit,
      addedAt: row.addedAt == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(row.addedAt!),
      startedAt: row.startedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.startedAt!),
      finishedAt: row.finishedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.finishedAt!),
    );
  }

  List<String> _decodeStringList(String? json) {
    if (json == null || json.isEmpty) return const [];
    return (jsonDecode(json) as List<dynamic>).cast<String>();
  }
}
