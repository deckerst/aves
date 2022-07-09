import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'aves_platform_meta_platform_interface.dart';

class MethodChannelAvesPlatformMeta extends AvesPlatformMetaPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('deckers.thibault/aves/aves_platform_meta');

  @override
  Future<String?> getMetadata(String key) {
    return methodChannel.invokeMethod<String>('getMetadata', <String, dynamic>{
      'key': key,
    });
  }
}
