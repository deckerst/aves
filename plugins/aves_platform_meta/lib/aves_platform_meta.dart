import 'aves_platform_meta_platform_interface.dart';

class AvesPlatformMeta {
  Future<String?> getMetadata(String key) {
    return AvesPlatformMetaPlatform.instance.getMetadata(key);
  }
}
