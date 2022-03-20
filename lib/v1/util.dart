T getOrDefault<T>(List<T> list, int index, T defaultValue) {
  if (index < 0 || index >= list.length) {
    return defaultValue;
  }

  var value = list[index];

  if (value == null) {
    return defaultValue;
  }

  return value;
}
