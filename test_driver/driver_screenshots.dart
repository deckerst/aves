import 'package:aves/main_play.dart' as app;
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  enableFlutterDriverExtension();

  // something like `configure().then((_) => app.main());` does not behave as expected
  // and starts the app without waiting for `configure` to complete
  configureAndLaunch();
}

Future<void> configureAndLaunch() async {
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
    // viewer
    ..showOverlayOnOpening = true
    ..showOverlayMinimap = false
    ..showOverlayInfo = true
    ..showOverlayShootingDetails = false
    ..enableOverlayBlurEffect = true
    ..viewerUseCutout = true
    // info
    ..infoMapStyle = EntryMapStyle.stamenWatercolor
    ..infoMapZoom = 11
    ..coordinateFormat = CoordinateFormat.dms
    ..unitSystem = UnitSystem.metric;

  // TODO TLAD covers.set(LocationFilter(LocationLevel.country, location), contentId)

  app.main();
}
