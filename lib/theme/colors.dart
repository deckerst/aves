import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:provider/provider.dart';

class AColors {
  static const starEnabled = Colors.amber;
  static const starDisabled = Colors.grey;
  static const warning = Colors.amber;

  static const boraBoraGradient = [
    Color(0xff2bc0e4),
    Color(0xffeaecc6),
  ];
}

class AvesColorsProvider extends StatelessWidget {
  final bool allowMonochrome;
  final Widget child;

  static final Map<(AvesThemeColorMode, bool), AvesColorsData> _schemeCache = {};

  const AvesColorsProvider({
    super.key,
    this.allowMonochrome = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, AvesColorsData>(
      update: (context, settings, _) {
        final isDark = Theme.of(context).isDark;
        var mode = settings.themeColorMode;
        if (!allowMonochrome && mode == AvesThemeColorMode.monochrome) {
          mode = AvesThemeColorMode.polychrome;
        }
        return _schemeCache.putIfAbsent((mode, isDark), () {
          return switch (mode) {
            .monochrome => isDark ? _MonochromeOnDark() : _MonochromeOnLight(),
            .polychrome => isDark ? _NeonOnDark() : _PastelOnLight(),
          };
        });
      },
      child: child,
    );
  }
}

abstract class AvesColorsData {
  static const defaultAccent = Colors.indigoAccent;
  static const _neutralOnDark = Colors.white;
  static const _neutralOnLight = Color(0xAA000000);

  Color get neutral;

  Color fromHue(double hue);

  Color? fromBrandColor(Color? color);

  final Map<String, Future<Color>?> _appColors = {};
  final Map<String, Color> _stringColors = {};

  Color fromString(String string) {
    return _stringColors.putIfAbsent(string, () {
      final hash = string.codeUnits.fold<int>(0, (prev, v) => prev = v + ((prev << 5) - prev));
      final hue = (hash % 360).toDouble();
      return fromHue(hue);
    });
  }

  Future<Color>? appColor(String album) {
    final packageName = covers.effectiveAlbumPackage(album);
    if (packageName == null) return null;

    return _appColors.putIfAbsent(album, () {
      return appColorFromPackageName(packageName);
    });
  }

  static Future<Color> appColorFromPackageName(String packageName) async {
    final appIconImage = AppIconImage(packageName: packageName, size: 24);
    final scheme = await ColorExtractor.getDynamicScheme(
      provider: appIconImage,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return Color(MaterialDynamicColors.primaryFixedDim.getArgb(scheme));
  }

  void clearAppColor(String album) => _appColors.remove(album);

  // mime
  Color get image => fromHue(243);

  Color get video => fromHue(323);

  // type
  Color get favourite => fromHue(0);

  Color get animated => fromHue(83);

  Color get geotiff => fromHue(70);

  Color get motionPhoto => fromHue(104);

  Color get panorama => fromHue(5);

  Color get raw => fromHue(208);

  Color get slowMotionVideo => fromHue(333);

  Color get sphericalVideo => fromHue(174);

  // albums
  Color get albumCamera => fromHue(165);

  Color get albumDownload => fromHue(104);

  Color get albumScreenshots => fromHue(149);

  Color get albumScreenRecordings => fromHue(222);

  Color get albumVideoCaptures => fromHue(266);

  // info
  Color get xmp => fromHue(275);

  // settings
  Color get accessibility => fromHue(134);

  Color get display => fromHue(50);

  Color get language => fromHue(264);

  Color get navigation => fromHue(140);

  Color get privacy => fromHue(344);

  Color get thumbnails => fromHue(87);

  // debug
  static const debugGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.red,
      Colors.amber,
    ],
  );
}

abstract class _Monochrome extends AvesColorsData {
  @override
  Color fromHue(double hue) => neutral;

  @override
  Color? fromBrandColor(Color? color) => neutral;

  @override
  Color fromString(String string) => neutral;

  @override
  Future<Color>? appColor(String album) => SynchronousFuture(neutral);
}

class _MonochromeOnDark extends _Monochrome {
  @override
  Color get neutral => AvesColorsData._neutralOnDark;
}

class _MonochromeOnLight extends _Monochrome {
  @override
  Color get neutral => AvesColorsData._neutralOnLight;
}

class _NeonOnDark extends AvesColorsData {
  @override
  Color get neutral => AvesColorsData._neutralOnDark;

  @override
  Color fromHue(double hue) => HSLColor.fromAHSL(1.0, hue, .8, .6).toColor();

  @override
  Color? fromBrandColor(Color? color) => color;
}

class _PastelOnLight extends AvesColorsData {
  @override
  Color get neutral => AvesColorsData._neutralOnLight;

  @override
  Color fromHue(double hue) => _pastellize(HSLColor.fromAHSL(1.0, hue, .8, .6).toColor());

  @override
  Color? fromBrandColor(Color? color) => color != null ? _pastellize(color) : null;

  Color _pastellize(Color color) => Color.lerp(color, Colors.white, .5)!;
}
