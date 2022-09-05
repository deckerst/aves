import 'package:collection/collection.dart';

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
