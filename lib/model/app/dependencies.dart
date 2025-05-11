import 'package:aves/app_flavor.dart';

class Dependencies {
  static const String apache2 = 'Apache License 2.0';
  static const String bsd2 = 'BSD 2-Clause “Simplified” License';
  static const String bsd3 = 'BSD 3-Clause “Revised” License';
  static const String eclipse1 = 'Eclipse Public License 1.0';
  static const String lgpl3 = 'GNU Lesser General Public License v3.0';
  static const String mit = 'MIT License';
  static const String zlib = 'zlib License';

  static const List<Dependency> androidDependencies = [
    Dependency(
      name: 'AndroidSVG (Aves fork)',
      license: apache2,
      sourceUrl: 'https://github.com/deckerst/androidsvg',
    ),
    Dependency(
      name: 'AndroidX (Core Kotlin, Exifinterface, Lifecycle Process, Multidex)',
      license: apache2,
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
      sourceUrl: 'https://github.com/deckerst/Android-TiffBitmapFactory',
    ),
  ];

  static const List<Dependency> _flutterPluginsCommon = [
    Dependency(
      name: 'Connectivity Plus',
      license: bsd3,
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/connectivity_plus',
    ),
    Dependency(
      name: 'Device Info Plus',
      license: bsd3,
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/device_info_plus',
    ),
    Dependency(
      name: 'Dynamic Color',
      license: apache2,
      sourceUrl: 'https://github.com/material-foundation/flutter-packages/tree/main/packages/dynamic_color',
    ),
    Dependency(
      name: 'Floating',
      license: mit,
      sourceUrl: 'https://github.com/wrbl606/floating',
    ),
    Dependency(
      name: 'Flutter Display Mode',
      license: mit,
      sourceUrl: 'https://github.com/ajinasokan/flutter_displaymode',
    ),
    Dependency(
      name: 'Local Auth',
      license: bsd3,
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/local_auth/local_auth',
    ),
    Dependency(
      name: 'Media Kit',
      license: mit,
      sourceUrl: 'https://github.com/media-kit/media-kit',
    ),
    Dependency(
      name: 'Network Info Plus',
      license: bsd3,
      sourceUrl: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/network_info_plus',
    ),
    Dependency(
      name: 'Package Info Plus',
      license: bsd3,
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
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences',
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
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/url_launcher/url_launcher',
    ),
    Dependency(
      name: 'Volume Controller',
      license: mit,
      sourceUrl: 'https://github.com/kurenai7968/volume_controller',
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
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/google_maps_flutter/google_maps_flutter',
    ),
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
        if (flavor == AppFlavor.izzy) ..._flutterPluginsIzzyOnly,
        if (flavor == AppFlavor.libre) ..._flutterPluginsLibreOnly,
        if (flavor == AppFlavor.play) ..._flutterPluginsPlayOnly,
      ];

  static const List<Dependency> flutterPackages = [
    Dependency(
      name: 'Charts (Aves fork)',
      license: apache2,
      sourceUrl: 'https://github.com/deckerst/flutter_google_charts',
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
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/flutter_markdown',
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
      name: 'Material Symbols Icons for Flutter',
      license: apache2,
      sourceUrl: 'https://github.com/timmaffett/material_symbols_icons',
    ),
    Dependency(
      name: 'Overlay Support',
      license: apache2,
      sourceUrl: 'https://github.com/boyan01/overlay_support',
    ),
    Dependency(
      name: 'Palette Generator',
      license: bsd3,
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/palette_generator',
    ),
    Dependency(
      name: 'Panorama (Aves fork)',
      license: apache2,
      sourceUrl: 'https://github.com/deckerst/aves_panorama',
    ),
    Dependency(
      name: 'Pattern Lock',
      license: apache2,
      sourceUrl: 'https://github.com/qwert2603/pattern_lock',
    ),
    Dependency(
      name: 'Percent Indicator',
      license: bsd2,
      sourceUrl: 'https://github.com/diegoveloper/flutter_percent_indicator',
    ),
    Dependency(
      name: 'Pin Code Fields',
      license: mit,
      sourceUrl: 'https://github.com/adar2378/pin_code_fields',
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
    Dependency(
      name: 'Vector Map Tiles',
      license: bsd3,
      sourceUrl: 'https://github.com/greensopinion/flutter-vector-map-tiles',
    ),
    Dependency(
      name: 'Vector Tile Renderer',
      license: bsd3,
      sourceUrl: 'https://github.com/greensopinion/dart-vector-tile-renderer',
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
      name: 'DLNA Dart',
      license: bsd3,
      sourceUrl: 'https://github.com/suconghou/dlna-dart',
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
      sourceUrl: 'https://github.com/flutter/packages/tree/main/packages/flutter_lints',
    ),
    Dependency(
      name: 'Get It',
      license: mit,
      sourceUrl: 'https://github.com/fluttercommunity/get_it',
    ),
    Dependency(
      name: 'GPX',
      license: apache2,
      sourceUrl: 'https://github.com/kb0/dart-gpx',
    ),
    Dependency(
      name: 'HTTP',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/http',
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
      name: 'Memory Leak Tracker',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/leak_tracker',
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
      name: 'Shelf',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/shelf',
    ),
    Dependency(
      name: 'Stack Trace',
      license: bsd3,
      sourceUrl: 'https://github.com/dart-lang/stack_trace',
    ),
    Dependency(
      name: 'Synchronized',
      license: mit,
      sourceUrl: 'https://github.com/tekartik/synchronized.dart/tree/master/synchronized',
    ),
    Dependency(
      name: 'Vector Math',
      license: '$zlib, $bsd3',
      sourceUrl: 'https://github.com/google/vector_math.dart',
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

  const Dependency({
    required this.name,
    required this.license,
    required this.sourceUrl,
  });
}
