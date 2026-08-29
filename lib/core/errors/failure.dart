/// What can go wrong in a repository call. Deliberately small — grows as
/// real failure modes show up, not speculatively.
sealed class Failure {
  const Failure(this.message);

  /// Developer-facing detail (logs), not what the user sees — see
  /// `error_mapper.dart` for user-facing copy.
  final String message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// §25 auth failures (sign up/in/out, OAuth, password reset). Lives here,
/// not in `auth_repository.dart` — `Failure` is `sealed`, so every
/// subtype must be declared in this library for the `error_mapper.dart`
/// switch to stay exhaustive.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// §8.4 point 4: moving an occurrence onto a date that already holds one
/// for the same plan. Carries the id of the row already there so the
/// caller can offer "Merge, or keep both?" and re-call with a resolution.
class OccurrenceConflictFailure extends Failure {
  const OccurrenceConflictFailure(this.conflictingOccurrenceId)
    : super('An occurrence already exists on that date.');

  final String conflictingOccurrenceId;
}

/// §16.2/M8: an external provider (TMDB) needs an API key that isn't
/// configured at build time. Search/detail calls fail with this rather
/// than silently returning nothing, so the UI can show an honest
/// configuration message instead of an empty list (§16.7).
class ConfigurationFailure extends Failure {
  const ConfigurationFailure(super.message);
}

/// An external HTTP call failed — offline, timed out, rate-limited (429),
/// or the provider returned a non-2xx status.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {this.statusCode});

  final int? statusCode;

  bool get isRateLimited => statusCode == 429;
}

/// M8 Part 7/16/24: a Top-N list (5 films, 5 TV shows, 3 books) is already
/// at its cap. The UI's "replace a film" action calls `replace` instead of
/// `add` once it sees this.
class TopListFullFailure extends Failure {
  const TopListFullFailure(this.cap)
    : super('This list already has $cap items.');

  final int cap;
}

/// §17.3's "size cap 25MB per file" — checked before the file is copied
/// into local storage, not after.
class DocumentTooLargeFailure extends Failure {
  DocumentTooLargeFailure(this.fileSizeBytes, this.capBytes)
    : super('This file is ${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB — documents are capped at ${capBytes ~/ (1024 * 1024)}MB.');

  final int fileSizeBytes;
  final int capBytes;
}
