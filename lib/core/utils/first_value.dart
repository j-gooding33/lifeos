import 'dart:async';

/// `Stream.first` cancels its subscription synchronously from inside the
/// `onData` callback that delivers the first event. That's fine for most
/// streams, but Drift's `QueryStream` (returned by every repository's
/// `watchXxx` method) races with that synchronous cancel under
/// `NativeDatabase` and never completes the returned future — reproduced
/// and root-caused in a minimal repro outside any repository. Deferring
/// the cancel to the next microtask avoids the race. See DECISIONS.md.
Future<T> firstValue<T>(Stream<T> stream) {
  final completer = Completer<T>();
  late StreamSubscription<T> subscription;
  subscription = stream.listen(
    (value) {
      if (!completer.isCompleted) completer.complete(value);
    },
    onError: (Object error, StackTrace stackTrace) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace);
    },
  );
  unawaited(completer.future.whenComplete(() => Future.microtask(subscription.cancel)));
  return completer.future;
}
