import 'package:aves/main_play.dart' as app;
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => configureAndLaunch();

Future<void> configureAndLaunch() async {
  enableFlutterDriverExtension();
  await settings.init(monitorPlatformSettings: false);
  settings
    // app
    ..hasAcceptedTerms = true
    ..isInstalledAppAccessAllowed = true
    ..isErrorReportingAllowed = false
    ..setTileExtent(CollectionPage.routeName, 69)
    ..setTileLayout(CollectionPage.routeName, TileLayout.mosaic)
    ..setTileExtent(CountryListPage.routeName, 112)
    ..setTileLayout(CountryListPage.routeName, TileLayout.grid)
    // display
    ..themeBrightness = AvesThemeBrightness.dark
    ..themeColorMode = AvesThemeColorMode.polychrome
    ..enableDynamicColor = false
    ..enableBlurEffect = true
    // navigation
    ..keepScreenOn = KeepScreenOn.always
    ..setHome(HomePageSetting.collection)
    ..drawerTypeBookmarks = [null, FavouriteFilter.instance]
    ..drawerAlbumBookmarks = null
    ..bottomNavigationActions = SettingsDefaults.bottomNavigationActions
    // collection
    ..collectionSectionFactor = EntrySectionFactor.month
    ..collectionSortFactor = EntrySortFactor.date
    ..collectionBrowsingQuickActions = SettingsDefaults.collectionBrowsingQuickActions
    ..showThumbnailFavourite = false
    ..thumbnailLocationIcon = ThumbnailOverlayLocationIcon.none
    ..thumbnailTagIcon = ThumbnailOverlayTagIcon.none
    ..hiddenFilters = {}
    // viewer
    ..viewerQuickActions = SettingsDefaults.viewerQuickActions
    ..showOverlayOnOpening = true
    ..showOverlayMinimap = false
    ..overlayHistogramStyle = OverlayHistogramStyle.none
    ..showOverlayInfo = true
    ..showOverlayDescription = false
    ..showOverlayRatingTags = false
    ..showOverlayShootingDetails = false
    ..showOverlayThumbnailPreview = false
    ..viewerUseCutout = true
    // info
    ..infoMapZoom = 13
    ..coordinateFormat = CoordinateFormat.dms
    ..unitSystem = UnitSystem.metric
    // map
    ..mapStyle = EntryMapStyles.googleNormal
    // debug
    ..debugShowViewerTiles = false;
  app.main();
}
