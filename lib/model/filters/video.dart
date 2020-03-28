import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class VideoFilter extends CollectionFilter {
  static const type = 'video';

  @override
  bool filter(ImageEntry entry) => entry.isVideo;

  @override
  String get label => 'Video';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.movie, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is VideoFilter;
  }

  @override
  int get hashCode => 'VideoFilter'.hashCode;
}
