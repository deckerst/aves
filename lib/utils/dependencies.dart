import 'package:aves/app_flavor.dart';

class Dependencies {
  static const String apache2 = 'Apache License 2.0';
  static const String bsd2 = 'BSD 2-Clause "Simplified" License';
  static const String bsd3 = 'BSD 3-Clause "Revised" License';
  static const String eclipse1 = 'Eclipse Public License 1.0';
  static const String mit = 'MIT License';

  static const List<Dependency> androidDependencies = [
    Dependency(
      name: 'AndroidSVG',
      license: apache2,
      sourceUrl: 'https://github.com/BigBadaboom/androidsvg',
    ),
    Dependency(
      name: 'AndroidX (Core Kotlin, Exifinterface, Lifecycle Process, Multidex)',
      license: apache2,
      licenseUrl: 'https://android.googlesource.com/platform/frameworks/support/+/androidx-main/LICENSE.txt',
      sourceUrl: 'https://android.googlesource.com/platform/frameworks/support/+/androidx-main/core/core-ktx',
    ),
    Dependency(
      name: 'CWAC-Document',
      license: apache2,
      sourceUrl: 'https://github.com/commonsguy/cwac-document',
    ),
    Dependency(
      name: 'Glide',
      license: '$apache2, $bsd2',
      sourceUrl: 'https://github.com/bumptech/glide',
    ),
    Dependency(
      name: 'Metadata Extractor',
      license: apache2,
      sourceUrl: 'https://github.com/drewnoakes/metadata-extractor',
    ),
    Dependency(
      name: 'MP4 Parser (Aves fork)',
      license: apache2,
      sourceUrl: 'https://github.com/deckerst/mp4parser',
    ),
    Dependency(
      name: 'PixyMeta Android (Aves fork)',
      license: eclipse1,
      sourceUrl: 'https://github.com/deckerst/pixymeta-android',
    ),
    Dependency(
      name: 'Tiff Bitmap Factory (Aves fork)',
      license: mit,
      licenseUrl: 'https://github.com/deckerst/Android-TiffBitmapFactory/blob/master/license.txt',
      sourceUrl: 'https://github.com/deckerst/Android-TiffBitmapFactory',
    ),
  ];

  static const List<Dependency> _flutterPluginsCommon = [
    Dependency(
      name: 'Connectivity Plus',
      license: bsd3,
      licenseUrl: 'https://github.com/fluttercommunity/plus_plugins/blob/main/packages/connectivity_plus/connectivity_plus/LICENSE',
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/connectivity_plus',
    ),
    Dependency(
      name: 'Device Info Plus',
      license: bsd3,
      licenseUrl: 'https://github.com/fluttercommunity/plus_plugins/blob/main/packages/device_info_plus/device_info_plus/LICENSE',
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/device_info_plus',
    ),
    Dependency(
      name: 'Dynamic Color',
      license: bsd3,
      sourceUrl: 'https://github.com/material-foundation/material-dynamic-color-flutter',
    ),
    Dependency(
      name: 'fijkplayer (Aves fork)',
      license: mit,
      sourceUrl: 'https://github.com/deckerst/fijkplayer',
    ),
    Dependency(
      name: 'Flutter Display Mode',
      license: mit,
      sourceUrl: 'https://github.com/ajinasokan/flutter_displaymode',
    ),
    Dependency(
      name: 'Package Info Plus',
      license: bsd3,
      licenseUrl: 'https://github.com/fluttercommunity/plus_plugins/blob/main/packages/package_info_plus/package_info_plus/LICENSE',
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/package_info_plus',
    ),
    Dependency(
      name: 'Permission Handler',
      license: mit,
      sourceUrl: 'https://github.com/Baseflow/flutter-permission-handler',
    ),
    Dependency(
      name: 'Printing',
      license: apache2,
      sourceUrl: 'https://github.com/DavBfr/dart_pdf',
    ),
    Dependency(
      name: 'Screen Brightness',
      license: mit,
      sourceUrl: 'https://github.com/aaassseee/screen_brightness',
    ),
    Dependency(
      name: 'Shared Preferences',
      license: bsd3,
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/shared_preferences/shared_preferences/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/shared_preferences/shared_preferences',
    ),
    Dependency(
      name: 'sqflite',
      license: bsd2,
      sourceUrl: 'https://github.com/tekartik/sqflite',
    ),
    Dependency(
      name: 'Streams Channel (Aves fork)',
      license: apache2,
      sourceUrl: 'https://github.com/deckerst/aves_streams_channel',
    ),
    Dependency(
      name: 'URL Launcher',
      license: bsd3,
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher',
    ),
  ];

  static const List<Dependency> _googleMobileServices = [
    Dependency(
      name: 'Google API Availability',
      license: mit,
      sourceUrl: 'https://github.com/Baseflow/flutter-google-api-availability',
    ),
    Dependency(
      name: 'Google Maps for Flutter',
      license: bsd3,
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/google_maps_flutter/google_maps_flutter/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter/google_maps_flutter',
    ),
  ];

  static const List<Dependency> _huaweiMobileServices = [
    Dependency(
      name: 'Huawei Mobile Services (Availability, Map)',
      license: apache2,
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

  static const List<Dependency> _flutterPluginsLibreOnly = [];

  static const List<Dependency> _flutterPluginsPlayOnly = [
    ..._googleMobileServices,
    Dependency(
      name: 'FlutterFire (Core, Crashlytics)',
      license: bsd3,
      sourceUrl: 'https://github.com/FirebaseExtended/flutterfire',
    ),
  ];

  static List<Dependency> flutterPlugins(AppFlavor flavor) => [
        ..._flutterPluginsCommon,
        if (flavor == AppFlavor.huawei) ..._flutterPluginsHuaweiOnly,
        if (flavor == AppFlavor.izzy) ..._flutterPluginsIzzyOnly,
        if (flavor == AppFlavor.libre) ..._flutterPluginsLibreOnly,
        if (flavor == AppFlavor.play) ..._flutterPluginsPlayOnly,
      ];

  static const List<Dependency> flutterPackages = [
    Dependency(
      name: 'Charts',
      license: apache2,
      sourceUrl: 'https://github.com/google/charts',
    ),
    Dependency(
      name: 'Custom rounded rectangle border',
      license: mit,
      sourceUrl: 'https://github.com/lekanbar/custom_rounded_rectangle_border',
    ),
    Dependency(
      name: 'Decorated Icon',
      license: mit,
      sourceUrl: 'https://github.com/benPesso/flutter_decorated_icon',
    ),
    Dependency(
      name: 'Expansion Tile Card (Aves fork)',
      license: bsd3,
      sourceUrl: 'https://github.com/deckerst/expansion_tile_card',
    ),
    Dependency(
      name: 'FlexColorPicker',
      license: bsd3,
      sourceUrl: 'https://github.com/rydmike/flex_color_picker',
    ),
    Dependency(
      name: 'Flutter Highlight',
      license: mit,
      sourceUrl: 'https://github.com/git-touch/highlight',
    ),
    Dependency(
      name: 'Flutter Map',
      license: bsd3,
      sourceUrl: 'https://github.com/fleaflet/flutter_map',
    ),
    Dependency(
      name: 'Flutter Markdown',
      license: bsd3,
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/flutter_markdown/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/flutter_markdown',
    ),
    Dependency(
      name: 'Flutter Staggered Animations',
      license: mit,
      sourceUrl: 'https://github.com/mobiten/flutter_staggered_animations',
    ),
    Dependency(
      name: 'Material Design Icons Flutter',
      license: mit,
      sourceUrl: 'https://github.com/ziofat/material_design_icons_flutter',
    ),
    Dependency(
      name: 'Overlay Support',
      license: apache2,
      sourceUrl: 'https://github.com/boyan01/overlay_support',
    ),
    Dependency(
      name: 'Palette Generator',
      license: bsd3,
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/palette_generator/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/palette_generator',
    ),
    Dependency(
      name: 'Panorama (Aves fork)',
      license: apache2,
      sourceUrl: 'https://github.com/zesage/panorama',
    ),
    Dependency(
      name: 'Percent Indicator',
      license: bsd2,
      sourceUrl: 'https://github.com/diegoveloper/flutter_percent_indicator',
    ),
    Dependency(
      name: 'Provider',
      license: mit,
      sourceUrl: 'https://github.com/rrousselGit/provider',
    ),
    Dependency(
      name: 'Smooth Page Indicator',
      license: mit,
      sourceUrl: 'https://github.com/Milad-Akarie/smooth_page_indicator',
    ),
  ];

  static const List<Dependency> dartPackages = [
    Dependency(
      name: 'Collection',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/collection',
    ),
    Dependency(
      name: 'Country Code',
      license: mit,
      sourceUrl: 'https://github.com/denixport/dart.country',
    ),
    Dependency(
      name: 'Equatable',
      license: mit,
      sourceUrl: 'https://github.com/felangel/equatable',
    ),
    Dependency(
      name: 'Event Bus',
      license: mit,
      sourceUrl: 'https://github.com/marcojakob/dart-event-bus',
    ),
    Dependency(
      name: 'Fluster',
      license: mit,
      sourceUrl: 'https://github.com/alfonsocejudo/fluster',
    ),
    Dependency(
      name: 'Flutter Lints',
      license: bsd3,
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/flutter_lints/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/flutter_lints',
    ),
    Dependency(
      name: 'Get It',
      license: mit,
      sourceUrl: 'https://github.com/fluttercommunity/get_it',
    ),
    Dependency(
      name: 'Intl',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/intl',
    ),
    Dependency(
      name: 'LatLong2',
      license: apache2,
      sourceUrl: 'https://github.com/jifalops/dart-latlong',
    ),
    Dependency(
      name: 'Material Color Utilities',
      license: apache2,
      licenseUrl: 'https://github.com/material-foundation/material-color-utilities/tree/main/dart/LICENSE',
      sourceUrl: 'https://github.com/material-foundation/material-color-utilities/tree/main/dart',
    ),
    Dependency(
      name: 'Path',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/path',
    ),
    Dependency(
      name: 'PDF for Dart and Flutter',
      license: apache2,
      sourceUrl: 'https://github.com/DavBfr/dart_pdf',
    ),
    Dependency(
      name: 'Proj4dart',
      license: mit,
      sourceUrl: 'https://github.com/maRci002/proj4dart',
    ),
    Dependency(
      name: 'Stack Trace',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/stack_trace',
    ),
    Dependency(
      name: 'Transparent Image',
      license: mit,
      sourceUrl: 'https://github.com/brianegan/transparent_image',
    ),
    Dependency(
      name: 'Tuple',
      license: bsd2,
      sourceUrl: 'https://github.com/google/tuple.dart',
    ),
    Dependency(
      name: 'XML',
      license: mit,
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
