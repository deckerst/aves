import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraHomePageSetting on HomePageSetting {
  String get routeName {
    switch (this) {
      case HomePageSetting.collection:
        return CollectionPage.routeName;
      case HomePageSetting.albums:
        return AlbumListPage.routeName;
      case HomePageSetting.tags:
        return TagListPage.routeName;
    }
  }
}
