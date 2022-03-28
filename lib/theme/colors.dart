import 'package:aves/image_providers/app_icon_image_provider.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class AvesColorsProvider extends StatelessWidget {
  final Widget child;

  const AvesColorsProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<Settings, AvesColorsData>(
      update: (context, settings, __) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        switch (settings.themeColorMode) {
          case AvesThemeColorMode.monochrome:
            return isDark ? _MonochromeOnDark() : _MonochromeOnLight();
          case AvesThemeColorMode.polychrome:
            return isDark ? NeonOnDark() : PastelOnLight();
        }
      },
      child: child,
    );
  }
}

abstract class AvesColorsData {
  Color get neutral;

  Color fromHue(double hue);

  Color? fromBrandColor(Color? color);

  final Map<String, Color> _stringColors = {}, _appColors = {};

  Color fromString(String string) {
    var color = _stringColors[string];
    if (color == null) {
      final hash = string.codeUnits.fold<int>(0, (prev, el) => prev = el + ((prev << 5) - prev));
      final hue = (hash % 360).toDouble();
      color = fromHue(hue);
      _stringColors[string] = color;
    }
    return color;
  }

  Future<Color>? appColor(String album) {
    if (_appColors.containsKey(album)) return SynchronousFuture(_appColors[album]!);

    final packageName = androidFileUtils.getAlbumAppPackageName(album);
    if (packageName == null) return null;

    return PaletteGenerator.fromImageProvider(
      AppIconImage(packageName: packageName, size: 24),
    ).then((palette) async {
      // `dominantColor` is most representative but can have low contrast with a dark background
      // `vibrantColor` is usually representative and has good contrast with a dark background
      final color = palette.vibrantColor?.color ?? fromString(album);
      _appColors[album] = color;
      return color;
    });
  }

  static const Color _neutralOnDark = Colors.white;
  static const Color _neutralOnLight = Color(0xAA000000);

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

class NeonOnDark extends AvesColorsData {
  @override
  Color get neutral => AvesColorsData._neutralOnDark;

  @override
  Color fromHue(double hue) => HSLColor.fromAHSL(1.0, hue, .8, .6).toColor();

  @override
  Color? fromBrandColor(Color? color) => color;
}

class PastelOnLight extends AvesColorsData {
  @override
  Color get neutral => AvesColorsData._neutralOnLight;

  @override
  Color fromHue(double hue) => _pastellize(HSLColor.fromAHSL(1.0, hue, .8, .6).toColor());

  @override
  Color? fromBrandColor(Color? color) => color != null ? _pastellize(color) : null;

  Color _pastellize(Color color) => Color.lerp(color, Colors.white, .5)!;
}
