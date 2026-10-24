import 'package:aves/utils/string_utils.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class XmpProp(
  final String path,
  final String value,
) implements Comparable<XmpProp> {
  final String displayKey = formatKey(path);

  static String formatKey(String propPath) {
    return propPath.splitMapJoin(
      XMP.structFieldSeparator,
      onMatch: (match) => ' ${match.group(0)} ',
      onNonMatch: (s) {
        // strip namespace
        final key = s.split(XMP.propNamespaceSeparator).last;
        // format
        return key.replaceAll('_', ' ').toSentenceCase();
      },
    );
  }

  @override
  int compareTo(XmpProp other) => compareAsciiUpperCaseNatural(displayKey, other.displayKey);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{path=$path, value=$value}';
}
