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
