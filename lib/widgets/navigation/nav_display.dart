import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationDisplay {
  static String getFilterTitle(BuildContext context, CollectionFilter? filter) {
    final l10n = context.l10n;
    if (filter == null) return l10n.drawerCollectionAll;
    if (filter == FavouriteFilter.instance) return l10n.drawerCollectionFavourites;
    if (filter == MimeFilter.image) return l10n.drawerCollectionImages;
    if (filter == MimeFilter.video) return l10n.drawerCollectionVideos;
    if (filter == TypeFilter.animated) return l10n.drawerCollectionAnimated;
    if (filter == TypeFilter.motionPhoto) return l10n.drawerCollectionMotionPhotos;
    if (filter == TypeFilter.panorama) return l10n.drawerCollectionPanoramas;
    if (filter == TypeFilter.raw) return l10n.drawerCollectionRaws;
    if (filter == TypeFilter.sphericalVideo) return l10n.drawerCollectionSphericalVideos;
    return filter.getLabel(context);
  }

  static String getPageTitle(BuildContext context, route) {
    final l10n = context.l10n;
    switch (route) {
      case AlbumListPage.routeName:
        return l10n.drawerAlbumPage;
      case CountryListPage.routeName:
        return l10n.drawerCountryPage;
      case TagListPage.routeName:
        return l10n.drawerTagPage;
      case SettingsPage.routeName:
        return l10n.settingsPageTitle;
      case AboutPage.routeName:
        return l10n.aboutPageTitle;
      case AppDebugPage.routeName:
        return 'Debug';
      default:
        return route;
    }
  }

  static IconData? getPageIcon(String route) {
    switch (route) {
      case AlbumListPage.routeName:
        return AIcons.album;
      case CountryListPage.routeName:
        return AIcons.location;
      case TagListPage.routeName:
        return AIcons.tag;
      case SettingsPage.routeName:
        return AIcons.settings;
      case AboutPage.routeName:
        return AIcons.info;
      case AppDebugPage.routeName:
        return AIcons.debug;
      default:
        return null;
    }
  }
}
