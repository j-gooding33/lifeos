/// Repositories return this instead of throwing across a layer boundary
/// (CLAUDE.md conventions).
sealed class Result<T, F> {
  const Result();

  R when<R>({required R Function(T value) ok, required R Function(F failure) err}) {
    final self = this;
    return switch (self) {
      Ok<T, F>() => ok(self.value),
      Err<T, F>() => err(self.failure),
    };
  }

  bool get isOk => this is Ok<T, F>;
}

final class Ok<T, F> extends Result<T, F> {
  const Ok(this.value);
  final T value;
}

final class Err<T, F> extends Result<T, F> {
  const Err(this.failure);
  final F failure;
}
