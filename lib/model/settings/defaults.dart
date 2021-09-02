import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/entry_set_actions.dart';
import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';

class SettingsDefaults {
  // drawer
  static final drawerTypeBookmarks = [
    null,
    MimeFilter.video,
    FavouriteFilter.instance,
  ];
  static final drawerPageBookmarks = [
    AlbumListPage.routeName,
    CountryListPage.routeName,
    TagListPage.routeName,
  ];

  // collection
  static const collectionSelectionQuickActions = [
    EntrySetAction.share,
    EntrySetAction.delete,
  ];

  // viewer
  static const viewerQuickActions = [
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.rotateScreen,
  ];

  // video
  static const videoQuickActions = [
    VideoAction.replay10,
    VideoAction.togglePlay,
  ];
}
