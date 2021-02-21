import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:latlong/latlong.dart';

class Constants {
  // as of Flutter v1.22.3, overflowing `Text` miscalculates height and some text (e.g. 'Å') is clipped
  // so we give it a `strutStyle` with a slightly larger height
  static const overflowStrutStyle = StrutStyle(height: 1.3);

  static const titleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.enable('smcp')],
  );

  static const embossShadow = Shadow(
    color: Colors.black87,
    offset: Offset(0.5, 1.0),
  );

  static const overlayUnknown = '—'; // em dash
  static const infoUnknown = 'unknown';

  static final pointNemo = LatLng(-48.876667, -123.393333);

  static const int infoGroupMaxValueLength = 140;

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
      name: 'Android-TiffBitmapFactory',
      license: 'MIT',
      licenseUrl: 'https://github.com/Beyka/Android-TiffBitmapFactory/blob/master/license.txt',
      sourceUrl: 'https://github.com/Beyka/Android-TiffBitmapFactory',
    ),
    Dependency(
      name: 'CWAC-Document',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/commonsguy/cwac-document/blob/master/LICENSE',
      sourceUrl: 'https://github.com/commonsguy/cwac-document',
    ),
    Dependency(
      name: 'Glide',
      license: 'Apache 2.0, BSD 2-Clause',
      licenseUrl: 'https://github.com/bumptech/glide/blob/master/LICENSE',
      sourceUrl: 'https://github.com/bumptech/glide',
    ),
    Dependency(
      name: 'Metadata Extractor',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/drewnoakes/metadata-extractor/blob/master/LICENSE',
      sourceUrl: 'https://github.com/drewnoakes/metadata-extractor',
    ),
  ];

  static const List<Dependency> flutterPackages = [
    Dependency(
      name: 'Flutter',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/flutter/blob/master/LICENSE',
      sourceUrl: 'https://github.com/flutter/flutter',
    ),
    Dependency(
      name: 'Charts',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/google/charts/blob/master/LICENSE',
      sourceUrl: 'https://github.com/google/charts',
    ),
    Dependency(
      name: 'Collection',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/dart-lang/collection/blob/master/LICENSE',
      sourceUrl: 'https://github.com/dart-lang/collection',
    ),
    Dependency(
      name: 'Connectivity',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/connectivity/connectivity/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/blob/master/packages/connectivity/connectivity',
    ),
    Dependency(
      name: 'Country Code',
      license: 'MIT',
      licenseUrl: 'https://github.com/denixport/dart.country/blob/master/LICENSE',
      sourceUrl: 'https://github.com/denixport/dart.country',
    ),
    Dependency(
      name: 'Decorated Icon',
      license: 'MIT',
      licenseUrl: 'https://github.com/benPesso/flutter_decorated_icon/blob/master/LICENSE',
      sourceUrl: 'https://github.com/benPesso/flutter_decorated_icon',
    ),
    Dependency(
      name: 'Event Bus',
      license: 'MIT',
      licenseUrl: 'https://github.com/marcojakob/dart-event-bus/blob/master/LICENSE',
      sourceUrl: 'https://github.com/marcojakob/dart-event-bus',
    ),
    Dependency(
      name: 'Expansion Tile Card',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/Skylled/expansion_tile_card/blob/master/LICENSE',
      sourceUrl: 'https://github.com/Skylled/expansion_tile_card',
    ),
    Dependency(
      name: 'FlutterFire (Core, Analytics, Crashlytics)',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/FirebaseExtended/flutterfire/blob/master/LICENSE',
      sourceUrl: 'https://github.com/FirebaseExtended/flutterfire',
    ),
    Dependency(
      name: 'Flushbar',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/AndreHaueisen/flushbar/blob/master/LICENSE',
      sourceUrl: 'https://github.com/AndreHaueisen/flushbar',
    ),
    Dependency(
      name: 'Flutter Highlight',
      license: 'MIT',
      licenseUrl: 'https://github.com/git-touch/highlight/blob/master/LICENSE',
      sourceUrl: 'https://github.com/git-touch/highlight',
    ),
    Dependency(
      name: 'Flutter ijkplayer',
      license: 'MIT',
      licenseUrl: 'https://github.com/CaiJingLong/flutter_ijkplayer/blob/master/LICENSE',
      sourceUrl: 'https://github.com/CaiJingLong/flutter_ijkplayer',
    ),
    Dependency(
      name: 'Flutter Map',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/fleaflet/flutter_map/blob/master/LICENSE',
      sourceUrl: 'https://github.com/fleaflet/flutter_map',
    ),
    Dependency(
      name: 'Flutter Markdown',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/flutter_markdown/blob/master/LICENSE',
      sourceUrl: 'https://github.com/flutter/flutter_markdown',
    ),
    Dependency(
      name: 'Flutter Staggered Animations',
      license: 'MIT',
      licenseUrl: 'https://github.com/mobiten/flutter_staggered_animations/blob/master/LICENSE',
      sourceUrl: 'https://github.com/mobiten/flutter_staggered_animations',
    ),
    Dependency(
      name: 'Flutter SVG',
      license: 'MIT',
      licenseUrl: 'https://github.com/dnfield/flutter_svg/blob/master/LICENSE',
      sourceUrl: 'https://github.com/dnfield/flutter_svg',
    ),
    Dependency(
      name: 'Geocoder',
      license: 'MIT',
      licenseUrl: 'https://github.com/aloisdeniel/flutter_geocoder/blob/master/LICENSE',
      sourceUrl: 'https://github.com/aloisdeniel/flutter_geocoder',
    ),
    Dependency(
      name: 'Github',
      license: 'MIT',
      licenseUrl: 'https://github.com/SpinlockLabs/github.dart/blob/master/LICENSE',
      sourceUrl: 'https://github.com/SpinlockLabs/github.dart',
    ),
    Dependency(
      name: 'Google Maps for Flutter',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/google_maps_flutter/google_maps_flutter/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/blob/master/packages/google_maps_flutter/google_maps_flutter',
    ),
    Dependency(
      name: 'Intl',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/dart-lang/intl/blob/master/LICENSE',
      sourceUrl: 'https://github.com/dart-lang/intl',
    ),
    Dependency(
      name: 'LatLong',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/MikeMitterer/dart-latlong/blob/master/LICENSE',
      sourceUrl: 'https://github.com/MikeMitterer/dart-latlong',
    ),
    Dependency(
      name: 'Material Design Icons Flutter',
      license: 'MIT',
      licenseUrl: 'https://github.com/ziofat/material_design_icons_flutter/blob/master/LICENSE',
      sourceUrl: 'https://github.com/ziofat/material_design_icons_flutter',
    ),
    Dependency(
      name: 'Overlay Support',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/boyan01/overlay_support/blob/master/LICENSE',
      sourceUrl: 'https://github.com/boyan01/overlay_support',
    ),
    Dependency(
      name: 'Package Info',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/package_info/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/package_info',
    ),
    Dependency(
      name: 'Palette Generator',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/packages/blob/master/packages/palette_generator/LICENSE',
      sourceUrl: 'https://github.com/flutter/packages/tree/master/packages/palette_generator',
    ),
    Dependency(
      name: 'Panorama',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/zesage/panorama/blob/master/LICENSE',
      sourceUrl: 'https://github.com/zesage/panorama',
    ),
    Dependency(
      name: 'PDF for Dart and Flutter',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/DavBfr/dart_pdf/blob/master/LICENSE',
      sourceUrl: 'https://github.com/DavBfr/dart_pdf',
    ),
    Dependency(
      name: 'Pedantic',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/dart-lang/pedantic/blob/master/LICENSE',
      sourceUrl: 'https://github.com/dart-lang/pedantic',
    ),
    Dependency(
      name: 'Percent Indicator',
      license: 'BSD 2-Clause',
      licenseUrl: 'https://github.com/diegoveloper/flutter_percent_indicator/blob/master/LICENSE',
      sourceUrl: 'https://github.com/diegoveloper/flutter_percent_indicator/',
    ),
    Dependency(
      name: 'Permission Handler',
      license: 'MIT',
      licenseUrl: 'https://github.com/Baseflow/flutter-permission-handler/blob/develop/permission_handler/LICENSE',
      sourceUrl: 'https://github.com/Baseflow/flutter-permission-handler',
    ),
    Dependency(
      name: 'Printing',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/DavBfr/dart_pdf/blob/master/LICENSE',
      sourceUrl: 'https://github.com/DavBfr/dart_pdf',
    ),
    Dependency(
      name: 'Provider',
      license: 'MIT',
      licenseUrl: 'https://github.com/rrousselGit/provider/blob/master/LICENSE',
      sourceUrl: 'https://github.com/rrousselGit/provider',
    ),
    Dependency(
      name: 'Shared Preferences',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/shared_preferences/shared_preferences/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/tree/master/packages/shared_preferences/shared_preferences',
    ),
    Dependency(
      name: 'sqflite',
      license: 'MIT',
      licenseUrl: 'https://github.com/tekartik/sqflite/blob/master/sqflite/LICENSE',
      sourceUrl: 'https://github.com/tekartik/sqflite',
    ),
    Dependency(
      name: 'Streams Channel',
      license: 'Apache 2.0',
      licenseUrl: 'https://github.com/loup-v/streams_channel/blob/master/LICENSE',
      sourceUrl: 'https://github.com/loup-v/streams_channel',
    ),
    Dependency(
      name: 'Tuple',
      license: 'BSD 2-Clause',
      licenseUrl: 'https://github.com/dart-lang/tuple/blob/master/LICENSE',
      sourceUrl: 'https://github.com/dart-lang/tuple',
    ),
    Dependency(
      name: 'URL Launcher',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher/LICENSE',
      sourceUrl: 'https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher',
    ),
    Dependency(
      name: 'Version',
      license: 'BSD 3-Clause',
      licenseUrl: 'https://github.com/dartninja/version/blob/master/LICENSE',
      sourceUrl: 'https://github.com/dartninja/version',
    ),
    Dependency(
      name: 'XML',
      license: 'MIT',
      licenseUrl: 'https://github.com/renggli/dart-xml/blob/master/LICENSE',
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
    @required this.name,
    @required this.license,
    @required this.licenseUrl,
    @required this.sourceUrl,
  });
}
