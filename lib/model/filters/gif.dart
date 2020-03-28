import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class GifFilter extends CollectionFilter {
  static const type = 'gif';

  @override
  bool filter(ImageEntry entry) => entry.isGif;

  @override
  String get label => 'GIF';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.gif, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is GifFilter;
  }

  @override
  int get hashCode => 'GifFilter'.hashCode;
}
