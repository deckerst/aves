import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_mpv/aves_video_mpv.dart';
import 'package:media_kit/media_kit.dart';

class MpvVideoControllerFactory extends AvesVideoControllerFactory {
  @override
  void init() => MediaKit.ensureInitialized();

  @override
  AvesVideoController buildController(
    AvesEntryBase entry, {
    required PlaybackStateHandler playbackStateHandler,
    required VideoSettings settings,
  }) =>
      MpvVideoController(
        entry,
        playbackStateHandler: playbackStateHandler,
        settings: settings,
      );
}
