extension ExtraList<E> on List<E> {
  bool replace(E old, E newItem) {
    final index = indexOf(old);
    if (index == -1) return false;

    this[index] = newItem;
    return true;
  }
}

extension ExtraSet<E> on Set<E> {
  bool replace(E old, E newItem) {
    if (!remove(old)) return false;

    add(newItem);
    return true;
  }
}

extension ExtraMapNullableKey<K extends Object, V> on Map<K?, V> {
  Map<K, V> whereNotNullKey() => <K, V>{for (var v in keys.nonNulls) v: this[v] as V};
}

extension ExtraMapNullableValue<K extends Object, V> on Map<K, V?> {
  Map<K, V> whereNotNullValue() => <K, V>{for (var kv in entries.where((kv) => kv.value != null)) kv.key: kv.value as V};
}

extension ExtraMapNullableKeyValue<K extends Object, V> on Map<K?, V?> {
  Map<K, V?> whereNotNullKey() => <K, V?>{for (var v in keys.nonNulls) v: this[v]};

  Map<K?, V> whereNotNullValue() => <K?, V>{for (var kv in entries.where((kv) => kv.value != null)) kv.key: kv.value as V};
}

extension ExtraNumIterable on Iterable<int?> {
  int get sum => fold(0, (prev, v) => prev + (v ?? 0));
}

extension ExtraEnum<T extends Enum> on Iterable<T> {
  T safeByName(String name, T defaultValue) {
    try {
      return byName(name);
    } catch (error) {
      return defaultValue;
    }
  }
}
