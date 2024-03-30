import 'package:aves_video/aves_video.dart';
import 'package:media_kit/media_kit.dart';

extension ExtraVideoTrack on VideoTrack {
  MediaStreamSummary toAves(int index) {
    return MediaStreamSummary(
      type: MediaStreamType.video,
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
  MediaStreamSummary toAves(int index) {
    return MediaStreamSummary(
      type: MediaStreamType.audio,
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
  MediaStreamSummary toAves(int index) {
    return MediaStreamSummary(
      type: MediaStreamType.text,
      index: index,
      codecName: null,
      language: language,
      title: title,
      width: null,
      height: null,
    );
  }
}
