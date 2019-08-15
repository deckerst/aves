import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidAppService {
  static const platform = const MethodChannel('deckers.thibault/aves/app');

  static edit(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('edit', <String, dynamic>{
        'title': 'Edit with:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('edit failed with exception=${e.message}');
    }
  }

  static open(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('open', <String, dynamic>{
        'title': 'Open with:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('open failed with exception=${e.message}');
    }
  }

  static openMap(String geoUri) async {
    if (geoUri == null) return;
    try {
      await platform.invokeMethod('openMap', <String, dynamic>{
        'geoUri': geoUri,
      });
    } on PlatformException catch (e) {
      debugPrint('openMap failed with exception=${e.message}');
    }
  }

  static setAs(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('setAs', <String, dynamic>{
        'title': 'Set as:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('setAs failed with exception=${e.message}');
    }
  }

  static share(String uri, String mimeType) async {
    try {
      await platform.invokeMethod('share', <String, dynamic>{
        'title': 'Share via:',
        'uri': uri,
        'mimeType': mimeType,
      });
    } on PlatformException catch (e) {
      debugPrint('share failed with exception=${e.message}');
    }
  }
}
