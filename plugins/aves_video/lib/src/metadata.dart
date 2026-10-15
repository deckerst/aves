import 'dart:async';

abstract class AvesVideoMetadataFetcher {
  void init();

  Future<Map<String, Object?>> getMetadata({required String uri, required String mimeType});

  Future<(int, int?)> computeSlowMotionFactorAndDuration({required String uri, required String mimeType});
}
