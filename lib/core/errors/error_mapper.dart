import 'package:life_os/core/errors/failure.dart';

/// Maps a [Failure] to copy a user can actually read — never the raw
/// exception message. Grows alongside `Failure`'s subtypes.
String mapFailureToMessage(Failure failure) {
  return switch (failure) {
    DatabaseFailure() =>
      'Something went wrong saving that. Your data is safe — try again.',
    NotFoundFailure() => "That doesn't seem to exist anymore.",
    AuthFailure() => "That didn't work. Check your details and try again.",
    OccurrenceConflictFailure() =>
      "There's already one on that day. Merge, or keep both?",
    ConfigurationFailure(:final message) => message,
    NetworkFailure(isRateLimited: true) =>
      'Searching is busy right now — try again in a moment.',
    NetworkFailure() =>
      "Couldn't reach the internet. Check your connection and try again.",
    TopListFullFailure(:final cap) =>
      'This list already has $cap items — remove one first, or replace it.',
    DocumentTooLargeFailure(:final message) => message,
  };
}
