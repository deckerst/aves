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
  // similar to `EnumByName` extension `byName()`,
  // but check full name too, and fall back to a default value
  T? safeByName(String? name, {bool ignoreCase = false}) {
    if (name == null) return null;

    if (ignoreCase) {
      name = name.toLowerCase();
      return _safeByName(name, (v) => v.name.toLowerCase());
    } else {
      return _safeByName(name, (v) => v.name);
    }
  }

  T? _safeByName(String name, String Function(T element) getter) {
    for (var value in this) {
      if (getter(value) == name) return value;
    }
    final separatorIndex = name.indexOf('.');
    if (separatorIndex > -1) {
      return _safeByName(name.substring(separatorIndex + 1), getter);
    }
    return null;
  }
}
