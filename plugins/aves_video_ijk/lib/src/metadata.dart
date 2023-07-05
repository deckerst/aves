import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_ijk/aves_video_ijk.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';

class IjkVideoMetadataFetcher extends AvesVideoMetadataFetcher {
  @override
  void init() => FijkLog.setLevel(FijkLogLevel.Warn);

  @override
  Future<Map> getMetadata(AvesEntryBase entry) async {
    final player = FijkPlayer();
    final info = await player.setDataSourceUntilPrepared(entry.uri).then((v) {
      return player.getInfo();
    }).catchError((error) {
      debugPrint('failed to get video metadata for entry=$entry, error=$error');
      return {};
    });
    await player.release();
    return info;
  }
}
