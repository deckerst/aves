import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/cards/xmp.dart';
import 'package:aves/widgets/viewer/info/metadata/model/xmp_prop.dart';

class XmpCardData(
  final RegExp pattern, {
  String? title,
  final Map<String, InfoValueSpanBuilder> Function(int? index, Map<String, XmpProp> data)? spanBuilders,
  final List<XmpCardData>? cards,
}) {
  final String title = title ?? XmpProp.formatKey(titlePattern.firstMatch(pattern.pattern)!.group(1)!);
  final bool indexed = pattern.pattern.contains(r'\[(\d+)\]');
  final Map<int?, XmpExtractedCard> data = {};

  bool get isEmpty => data.isEmpty && (cards?.every((card) => card.isEmpty) ?? true);

  static final titlePattern = RegExp(r'(.*?)[\\/]');

  XmpCardData cloneEmpty() {
    return XmpCardData(
      pattern,
      title: title,
      spanBuilders: spanBuilders,
      cards: cards?.map((v) => v.cloneEmpty()).toList(),
    );
  }

  bool extract(XmpProp prop) => indexed ? _extractIndexedStruct(prop) : _extractDirectStruct(prop);

  bool _extractDirectStruct(XmpProp prop) {
    final matches = pattern.allMatches(prop.path);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final field = match.group(1)!;

    final fields = data.putIfAbsent(null, () => (<String, XmpProp>{}, cards?.map((v) => v.cloneEmpty()).toList()));
    final _cards = fields.$2;
    if (_cards != null) {
      final fieldProp = XmpProp(field, prop.value);
      if (_cards.any((v) => v.extract(fieldProp))) {
        return true;
      }
    }

    fields.$1[field] = prop;
    return true;
  }

  bool _extractIndexedStruct(XmpProp prop) {
    final matches = pattern.allMatches(prop.path);
    if (matches.isEmpty) return false;

    final match = matches.first;
    final index = int.parse(match.group(1)!);
    final field = match.group(2)!;

    final fields = data.putIfAbsent(index, () => (<String, XmpProp>{}, cards?.map((v) => v.cloneEmpty()).toList()));
    final _cards = fields.$2;
    if (_cards != null) {
      final fieldProp = XmpProp(field, prop.value);
      if (_cards.any((v) => v.extract(fieldProp))) {
        return true;
      }
    }

    fields.$1[field] = prop;
    return true;
  }
}
