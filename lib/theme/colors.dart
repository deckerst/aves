import 'package:aves/utils/color_utils.dart';
import 'package:flutter/material.dart';

class AColors {
  // mime
  static final image = stringToColor('Image');
  static final video = stringToColor('Video');

  // type
  static const favourite = Colors.red;
  static final animated = stringToColor('Animated');
  static final geotiff = stringToColor('GeoTIFF');
  static final motionPhoto = stringToColor('Motion Photo');
  static final panorama = stringToColor('Panorama');
  static final raw = stringToColor('Raw');
  static final sphericalVideo = stringToColor('360° Video');

  // albums
  static final albumCamera = stringToColor('Camera');
  static final albumDownload = stringToColor('Download');
  static final albumScreenshots = stringToColor('Screenshots');
  static final albumScreenRecordings = stringToColor('Screen recordings');
  static final albumVideoCaptures = stringToColor('Video Captures');

  // info
  static final xmp = stringToColor('XMP');

  // settings
  static final accessibility = stringToColor('Accessibility');
  static final language = stringToColor('Language');
  static final navigation = stringToColor('Navigation');
  static final privacy = stringToColor('Privacy');
  static final thumbnails = stringToColor('Thumbnails');

  static const debugGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Colors.red,
      Colors.amber,
    ],
  );
}
