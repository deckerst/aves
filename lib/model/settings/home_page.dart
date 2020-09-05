import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';

enum HomePageSetting { collection, albums }

extension ExtraHomePageSetting on HomePageSetting {
  String get name {
    switch (this) {
      case HomePageSetting.collection:
        return 'Collection';
      case HomePageSetting.albums:
        return 'Albums';
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
