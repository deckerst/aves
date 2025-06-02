import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
mixin CoveredFilter on CollectionFilter {
  @override
  Future<Color> color(BuildContext context) {
    final customColor = covers.of(this)?.$3;
    if (customColor != null) {
      return SynchronousFuture(customColor);
    }
    return super.color(context);
  }
}
