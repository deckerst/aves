import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/app_icon_image_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  final String query;

  const QueryFilter(this.query);

  @override
  bool filter(ImageEntry entry) => entry.search(query);

  @override
  String get label => '${query}';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.formatQuote, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is QueryFilter && other.query == query;
  }

  @override
  int get hashCode => hashValues('MetadataFilter', query);
}
