import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_exo/aves_video_exo.dart';

class ExoVideoControllerFactory extends AvesVideoControllerFactory {
  @override
  void init() {}

  @override
  AvesVideoController buildController(
    AvesEntryBase entry, {
    required PlaybackStateHandler playbackStateHandler,
    required VideoSettings settings,
  }) => ExoVideoController(
    entry,
    playbackStateHandler: playbackStateHandler,
    settings: settings,
  );
}
