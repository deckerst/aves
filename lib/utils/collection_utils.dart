import 'package:collection/collection.dart';

extension ExtraList<E> on List<E> {
  bool replace(E old, E newItem) {
    final index = indexOf(old);
    if (index == -1) return false;

    this[index] = newItem;
    return true;
  }
}

extension ExtraMapNullableKey<K extends Object, V> on Map<K?, V> {
  Map<K, V> whereNotNullKey() => <K, V>{for (var v in keys.whereNotNull()) v: this[v] as V};
}

extension ExtraMapNullableValue<K extends Object, V> on Map<K, V?> {
  Map<K, V> whereNotNullValue() => <K, V>{for (var kv in entries.where((kv) => kv.value != null)) kv.key: kv.value as V};
}

extension ExtraMapNullableKeyValue<K extends Object, V> on Map<K?, V?> {
  Map<K, V?> whereNotNullKey() => <K, V?>{for (var v in keys.whereNotNull()) v: this[v]};

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
