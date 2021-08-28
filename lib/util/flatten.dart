extension FlattenIterable<T> on Iterable<Iterable<T>> {
  /// Flattens an [Iterable] of [Iterable] values of type [T] to a [List] of values of type [T].
  List<T> flatten() => expand((values) => values).toList();
}
