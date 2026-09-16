import 'package:aves/main_play.dart' as app;
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() {
  enableFlutterDriverExtension();
  settings.init(monitorPlatformSettings: false, shouldSanitize: false).then((_) {
    settings
      // app
      ..hasAcceptedTerms = true
      ..isInstalledAppAccessAllowed = true
      ..isErrorReportingAllowed = false
      ..setTileExtent(CollectionPage.routeName, 69)
      ..setTileLayout(CollectionPage.routeName, .mosaic)
      ..setTileExtent(CountryListPage.routeName, 112)
      ..setTileLayout(CountryListPage.routeName, .grid)
      // display
      ..themeBrightness = .dark
      ..themeColorMode = .polychrome
      ..enableDynamicColor = false
      ..enableBlurEffect = true
      // navigation
      ..keepScreenOn = .always
      ..setHome(.collection)
      ..drawerTypeBookmarks = [null, FavouriteFilter.instance]
      ..drawerAlbumBookmarks = null
      ..bottomNavigationActions = SettingsDefaults.bottomNavigationActions
      // collection
      ..collectionSectionFactor = .month
      ..collectionSortFactor = .date
      ..collectionBrowsingQuickActions = SettingsDefaults.collectionBrowsingQuickActions
      ..showThumbnailFavourite = false
      ..thumbnailLocationIcon = .none
      ..thumbnailTagIcon = .none
      ..hiddenFilters = {}
      // viewer
      ..viewerQuickActions = SettingsDefaults.viewerQuickActions
      ..showOverlayOnOpening = true
      ..showOverlayMinimap = false
      ..showOverlayZoomLevel = false
      ..overlayHistogramStyle = .none
      ..showOverlayInfo = true
      ..showOverlayDescription = false
      ..showOverlayRatingTags = false
      ..showOverlayShootingDetails = false
      ..showOverlayThumbnailPreview = false
      ..viewerUseCutout = true
      // info
      ..infoMapZoom = 13
      ..coordinateFormat = .dms
      ..unitSystem = .metric
      // map
      ..mapStyle = EntryMapStyles.googleNormal
      ..mapShowItemTracks = true
      // debug
      ..debugShowViewerTiles = false;
    app.main();
  });
}
