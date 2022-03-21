extension ListHelper<T> on List<T> {
  T getOrDefault(int index, T defaultValue) {
    if (index < 0 || index >= length) {
      return defaultValue;
    }

    return this[index] ?? defaultValue;
  }
}

Iterable<int> range({required int from, required int to}) {
  return Iterable.generate(to - from, (i) => from + i);
}

extension IntRange on int {
  Iterable<int> rangeUntil({required int from}) {
    return range(from: from, to: this);
  }

  Iterable<int> rangeTo({
    required int to,
  }) {
    return range(from: this, to: to);
  }
}
