import 'package:aves/main_play.dart' as app;
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
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
    ..keepScreenOn = KeepScreenOn.always
    ..homePage = HomePageSetting.collection
    ..setTileExtent(CountryListPage.routeName, 112)
    ..setTileLayout(CountryListPage.routeName, TileLayout.grid)
    // collection
    ..collectionSectionFactor = EntryGroupFactor.month
    ..collectionSortFactor = EntrySortFactor.date
    ..collectionBrowsingQuickActions = SettingsDefaults.collectionBrowsingQuickActions
    ..showThumbnailFavourite = false
    ..showThumbnailLocation = false
    ..hiddenFilters = {}
    // viewer
    ..viewerQuickActions = SettingsDefaults.viewerQuickActions
    ..showOverlayOnOpening = true
    ..showOverlayMinimap = false
    ..showOverlayInfo = true
    ..showOverlayShootingDetails = false
    ..showOverlayThumbnailPreview = false
    ..enableOverlayBlurEffect = true
    ..viewerUseCutout = true
    // info
    ..infoMapStyle = EntryMapStyle.stamenWatercolor
    ..infoMapZoom = 13
    ..coordinateFormat = CoordinateFormat.dms
    ..unitSystem = UnitSystem.metric;
  app.main();
}
