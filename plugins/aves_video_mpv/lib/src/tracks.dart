import 'package:aves_video/aves_video.dart';
import 'package:media_kit/media_kit.dart';

extension ExtraVideoTrack on VideoTrack {
  MediaTrackSummary toAves(int index) {
    return MediaTrackSummary(
      type: MediaTrackType.video,
      index: index,
      codecName: null,
      language: language,
      title: title,
      width: null,
      height: null,
    );
  }
}

extension ExtraAudioTrack on AudioTrack {
  MediaTrackSummary toAves(int index) {
    return MediaTrackSummary(
      type: MediaTrackType.audio,
      index: index,
      codecName: null,
      language: language,
      title: title,
      width: null,
      height: null,
    );
  }
}

extension ExtraSubtitleTrack on SubtitleTrack {
  MediaTrackSummary toAves(int index) {
    return MediaTrackSummary(
      type: MediaTrackType.text,
      index: index,
      codecName: null,
      language: language,
      title: title ?? '$index ($codec)',
      width: null,
      height: null,
    );
  }
}
