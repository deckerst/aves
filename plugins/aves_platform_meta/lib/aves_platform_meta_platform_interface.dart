import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'aves_platform_meta_method_channel.dart';

abstract class AvesPlatformMetaPlatform extends PlatformInterface {
  AvesPlatformMetaPlatform() : super(token: _token);

  static final Object _token = Object();

  static AvesPlatformMetaPlatform _instance = MethodChannelAvesPlatformMeta();

  static AvesPlatformMetaPlatform get instance => _instance;

  static set instance(AvesPlatformMetaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getMetadata(String key) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
