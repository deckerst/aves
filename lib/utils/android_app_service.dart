import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidAppService {
  static const platform = const MethodChannel('deckers.thibault/aves/app');

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
