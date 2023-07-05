import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_ijk/aves_video_ijk.dart';
import 'package:fijkplayer/fijkplayer.dart';

class IjkVideoControllerFactory extends AvesVideoControllerFactory {
  @override
  void init() => FijkLog.setLevel(FijkLogLevel.Warn);

  @override
  AvesVideoController buildController(
    AvesEntryBase entry, {
    required PlaybackStateHandler playbackStateHandler,
    required VideoSettings settings,
  }) =>
      IjkVideoController(
        entry,
        playbackStateHandler: playbackStateHandler,
        settings: settings,
      );
}
