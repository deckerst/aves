import 'dart:ui';

import 'package:aves/app_flavor.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Constants {
  // as of Flutter v2.8.0, overflowing `Text` miscalculates height and some text (e.g. 'Å') is clipped
  // so we give it a `strutStyle` with a slightly larger height
  static const overflowStrutStyle = StrutStyle(height: 1.3);

  static const titleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.enable('smcp')],
  );

  static const embossShadows = [
    Shadow(
      color: Colors.black,
      offset: Offset(0.5, 1.0),
    )
  ];

  // Bidi fun, cf https://www.unicode.org/reports/tr9/
  // First Strong Isolate
  static const fsi = '\u2068';

  // Pop Directional Isolate
  static const pdi = '\u2069';

  static const zwsp = '\u200B';

  static const overlayUnknown = '—'; // em dash

  static final pointNemo = LatLng(-48.876667, -123.393333);

  static final wonders = [
    LatLng(29.979167, 31.134167),
    LatLng(36.451000, 28.223615),
    LatLng(32.5355, 44.4275),
    LatLng(31.213889, 29.885556),
    LatLng(37.0379, 27.4241),
    LatLng(37.637861, 21.63),
    LatLng(37.949722, 27.363889),
  ];

  static const int infoGroupMaxValueLength = 140;

  static const String avesGithub = 'https://github.com/deckerst/aves';

  static const List<Dependency> androidDependencies = [
    Dependency(
      name: 'AndroidX Core-KTX',
      license: 'Apache 2.0',
      licenseUrl: 'https://android.googlesource.com/platform/frameworks/support/+/androidx-main/LICENSE.txt',
      sourceUrl: 'https://android.googlesource.com/platform/frameworks/support/+/androidx-main/core/core-ktx',
    ),
    Dependency(
      name: 'AndroidX Exifinterface',
      license: 'Apache 2.0',
      licenseUrl: 'https://android.googlesource.com/platform/frameworks/support/+/androidx-main/LICENSE.txt',
      sourceUrl: 'https://android.googlesource.com/platform/frameworks/support/+/androidx-main/exifinterface/exifinterface',
    ),
    Dependency(
      name: 'AndroidSVG',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/BigBadaboom/androidsvg',
    ),
    Dependency(
      name: 'Android-TiffBitmapFactory (Aves fork)',
      license: 'MIT',
      licenseUrl: 'https://github.com/deckerst/Android-TiffBitmapFactory/blob/master/license.txt',
      sourceUrl: 'https://github.com/deckerst/Android-TiffBitmapFactory',
    ),
    Dependency(
      name: 'CWAC-Document',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/commonsguy/cwac-document',
    ),
    Dependency(
      name: 'Glide',
      license: 'Apache 2.0, BSD 2-Clause',
      sourceUrl: 'https://github.com/bumptech/glide',
    ),
    Dependency(
      name: 'Metadata Extractor',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/drewnoakes/metadata-extractor',
    ),
    Dependency(
      name: 'PixyMeta Android (Aves fork)',
      license: 'Eclipse Public License 1.0',
      sourceUrl: 'https://github.com/deckerst/pixymeta-android',
    ),
  ];

  static const List<Dependency> _flutterPluginsCommon = [
    Dependency(
      name: 'Connectivity Plus',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/fluttercommunity/plus_plugins/blob/main/packages/connectivity_plus/connectivity_plus/LICENSE',
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/connectivity_plus',
    ),
    Dependency(
      name: 'Device Info Plus',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/fluttercommunity/plus_plugins/blob/main/packages/device_info_plus/device_info_plus/LICENSE',
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/device_info_plus',
    ),
    Dependency(
      name: 'Dynamic Color',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/material-foundation/material-dynamic-color-flutter',
    ),
    Dependency(
      name: 'fijkplayer (Aves fork)',
      license: 'MIT',
      sourceUrl: 'https://github.com/deckerst/fijkplayer',
    ),
    Dependency(
      name: 'Flutter Display Mode',
      license: 'MIT',
      sourceUrl: 'https://github.com/ajinasokan/flutter_displaymode',
    ),
    Dependency(
      name: 'Package Info Plus',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/fluttercommunity/plus_plugins/blob/main/packages/package_info_plus/package_info_plus/LICENSE',
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/package_info_plus',
    ),
    Dependency(
      name: 'Permission Handler',
      license: 'MIT',
      sourceUrl: 'https://github.com/Baseflow/flutter-permission-handler',
    ),
    Dependency(
      name: 'Printing',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/DavBfr/dart_pdf',
    ),
    Dependency(
      name: 'Screen Brightness',
      license: 'MIT',
      sourceUrl: 'https://github.com/aaassseee/screen_brightness',
    ),
    Dependency(
      name: 'Shared Preferences',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/shared_preferences/shared_preferences/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/shared_preferences/shared_preferences',
    ),
    Dependency(
      name: 'sqflite',
      license: 'BSD 2-Clause',
      sourceUrl: 'https://github.com/tekartik/sqflite',
    ),
    Dependency(
      name: 'Streams Channel (Aves fork)',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/deckerst/aves_streams_channel',
    ),
    Dependency(
      name: 'URL Launcher',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher',
    ),
  ];

  static const List<Dependency> _googleMobileServices = [
    Dependency(
      name: 'Google API Availability',
      license: 'MIT',
      sourceUrl: 'https://github.com/Baseflow/flutter-google-api-availability',
    ),
    Dependency(
      name: 'Google Maps for Flutter',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/google_maps_flutter/google_maps_flutter/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter/google_maps_flutter',
    ),
  ];

  static const List<Dependency> _huaweiMobileServices = [
    Dependency(
      name: 'Huawei Mobile Services (Availability, Map)',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/HMS-Core/hms-flutter-plugin/blob/master/LICENCE',
      sourceUrl: 'https://github.com/HMS-Core/hms-flutter-plugin',
    ),
  ];

  static const List<Dependency> _flutterPluginsHuaweiOnly = [
    ..._huaweiMobileServices,
  ];

  static const List<Dependency> _flutterPluginsIzzyOnly = [
    ..._googleMobileServices,
  ];

  static const List<Dependency> _flutterPluginsPlayOnly = [
    ..._googleMobileServices,
    Dependency(
      name: 'FlutterFire (Core, Crashlytics)',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/FirebaseExtended/flutterfire',
    ),
  ];

  static List<Dependency> flutterPlugins(AppFlavor flavor) => [
        ..._flutterPluginsCommon,
        if (flavor == AppFlavor.huawei) ..._flutterPluginsHuaweiOnly,
        if (flavor == AppFlavor.izzy) ..._flutterPluginsIzzyOnly,
        if (flavor == AppFlavor.play) ..._flutterPluginsPlayOnly,
      ];

  static const List<Dependency> flutterPackages = [
    Dependency(
      name: 'Charts',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/google/charts',
    ),
    Dependency(
      name: 'Custom rounded rectangle border',
      license: 'MIT',
      sourceUrl: 'https://github.com/lekanbar/custom_rounded_rectangle_border',
    ),
    Dependency(
      name: 'Decorated Icon',
      license: 'MIT',
      sourceUrl: 'https://github.com/benPesso/flutter_decorated_icon',
    ),
    Dependency(
      name: 'Expansion Tile Card (Aves fork)',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/deckerst/expansion_tile_card',
    ),
    Dependency(
      name: 'FlexColorPicker',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/rydmike/flex_color_picker',
    ),
    Dependency(
      name: 'Flutter Highlight',
      license: 'MIT',
      sourceUrl: 'https://github.com/git-touch/highlight',
    ),
    Dependency(
      name: 'Flutter Map',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/fleaflet/flutter_map',
    ),
    Dependency(
      name: 'Flutter Markdown',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/flutter_markdown/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/flutter_markdown',
    ),
    Dependency(
      name: 'Flutter Staggered Animations',
      license: 'MIT',
      sourceUrl: 'https://github.com/mobiten/flutter_staggered_animations',
    ),
    Dependency(
      name: 'Material Design Icons Flutter',
      license: 'MIT',
      sourceUrl: 'https://github.com/ziofat/material_design_icons_flutter',
    ),
    Dependency(
      name: 'Overlay Support',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/boyan01/overlay_support',
    ),
    Dependency(
      name: 'Palette Generator',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/palette_generator/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/palette_generator',
    ),
    Dependency(
      name: 'Panorama (Aves fork)',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/zesage/panorama',
    ),
    Dependency(
      name: 'Percent Indicator',
      license: 'BSD 2-Clause',
      sourceUrl: 'https://github.com/diegoveloper/flutter_percent_indicator',
    ),
    Dependency(
      name: 'Provider',
      license: 'MIT',
      sourceUrl: 'https://github.com/rrousselGit/provider',
    ),
  ];

  static const List<Dependency> dartPackages = [
    Dependency(
      name: 'Collection',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/dart-lang/collection',
    ),
    Dependency(
      name: 'Country Code',
      license: 'MIT',
      sourceUrl: 'https://github.com/denixport/dart.country',
    ),
    Dependency(
      name: 'Equatable',
      license: 'MIT',
      sourceUrl: 'https://github.com/felangel/equatable',
    ),
    Dependency(
      name: 'Event Bus',
      license: 'MIT',
      sourceUrl: 'https://github.com/marcojakob/dart-event-bus',
    ),
    Dependency(
      name: 'Fluster',
      license: 'MIT',
      sourceUrl: 'https://github.com/alfonsocejudo/fluster',
    ),
    Dependency(
      name: 'Flutter Lints',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/flutter_lints/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/flutter_lints',
    ),
    Dependency(
      name: 'Get It',
      license: 'MIT',
      sourceUrl: 'https://github.com/fluttercommunity/get_it',
    ),
    Dependency(
      name: 'Intl',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/dart-lang/intl',
    ),
    Dependency(
      name: 'LatLong2',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/jifalops/dart-latlong',
    ),
    Dependency(
      name: 'Material Color Utilities',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/material-foundation/material-color-utilities/tree/main/dart/LICENSE',
      sourceUrl: 'https://github.com/material-foundation/material-color-utilities/tree/main/dart',
    ),
    Dependency(
      name: 'Path',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/dart-lang/path',
    ),
    Dependency(
      name: 'PDF for Dart and Flutter',
      license: 'Apache 2.0',
      sourceUrl: 'https://github.com/DavBfr/dart_pdf',
    ),
    Dependency(
      name: 'Proj4dart',
      license: 'MIT',
      sourceUrl: 'https://github.com/maRci002/proj4dart',
    ),
    Dependency(
      name: 'Stack Trace',
      license: 'BSD 3-Clause',
      sourceUrl: 'https://github.com/dart-lang/stack_trace',
    ),
    Dependency(
      name: 'Transparent Image',
      license: 'MIT',
      sourceUrl: 'https://github.com/brianegan/transparent_image',
    ),
    Dependency(
      name: 'Tuple',
      license: 'BSD 2-Clause',
      sourceUrl: 'https://github.com/google/tuple.dart',
    ),
    Dependency(
      name: 'XML',
      license: 'MIT',
      sourceUrl: 'https://github.com/renggli/dart-xml',
    ),
  ];
}

class Dependency {
  final String name;
  final String license;
  final String sourceUrl;
  final String licenseUrl;

  const Dependency({
    required this.name,
    required this.license,
    String? licenseUrl,
    required this.sourceUrl,
  }) : licenseUrl = licenseUrl ?? '$sourceUrl/blob/master/LICENSE';
}
