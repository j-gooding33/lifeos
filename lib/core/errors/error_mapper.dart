import 'package:life_os/core/errors/failure.dart';

/// Maps a [Failure] to copy a user can actually read — never the raw
/// exception message. Grows alongside `Failure`'s subtypes.
String mapFailureToMessage(Failure failure) {
  return switch (failure) {
    DatabaseFailure() => 'Something went wrong saving that. Your data is safe — try again.',
    NotFoundFailure() => "That doesn't seem to exist anymore.",
    AuthFailure() => "That didn't work. Check your details and try again.",
  };
}
