import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/link_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_link.dart';
import 'package:uuid/uuid.dart';

/// §17.3. Manual save + optional title/tags — no Open Graph fetch; see
/// DECISIONS.md.
class LinkRepository {
  LinkRepository(this._dao);

  final LinkDao _dao;

  Stream<List<AppLink>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  Future<Result<AppLink, Failure>> createLink({
    required String userId,
    required String url,
    String? title,
    List<String> tags = const [],
  }) async {
    try {
      final link = AppLink(id: const Uuid().v4(), userId: userId, url: url, title: title, tags: tags);
      await _save(link);
      return Ok(link);
    } on Object catch (e) {
      return Err(DatabaseFailure('createLink failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateLink(AppLink link) async {
    try {
      await _save(link);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateLink failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteLink(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteLink failed: $e'));
    }
  }

  Future<void> _save(AppLink link) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.LinksCompanion(
        id: Value(link.id),
        userId: Value(link.userId),
        url: Value(link.url),
        title: Value(link.title),
        faviconUrl: Value(link.faviconUrl),
        tags: Value(jsonEncode(link.tags)),
        createdAt: Value(link.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppLink> _toDomainList(List<db.Link> rows) => rows.map(_toDomain).toList();

  AppLink _toDomain(db.Link row) {
    final rawTags = row.tags == null || row.tags!.isEmpty ? const <dynamic>[] : jsonDecode(row.tags!) as List<dynamic>;
    return AppLink(
      id: row.id,
      userId: row.userId,
      url: row.url,
      title: row.title,
      faviconUrl: row.faviconUrl,
      tags: rawTags.cast<String>(),
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
      updatedAt: row.updatedAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.updatedAt!),
    );
  }
}
