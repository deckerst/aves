import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraHomePageSetting on HomePageSetting {
  String getName(BuildContext context) {
    switch (this) {
      case HomePageSetting.collection:
        return context.l10n.collectionPageTitle;
      case HomePageSetting.albums:
        return context.l10n.albumPageTitle;
      default:
        return toString();
    }
  }

  String get routeName {
    switch (this) {
      case HomePageSetting.collection:
        return CollectionPage.routeName;
      case HomePageSetting.albums:
        return AlbumListPage.routeName;
      default:
        return toString();
    }
  }
}
