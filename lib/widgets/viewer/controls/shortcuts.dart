import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/widgets/viewer/controls/intents.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ViewerShortcuts {
  static const entryActions = {
    SingleActivator(LogicalKeyboardKey.delete): EntryActionIntent(action: EntryAction.delete),
  };

// cf https://developer.android.com/training/tv/start/controllers#media-events
  static const media = {
    // KEYCODE_MEDIA_PLAY_PAUSE / 85 / play/pause
    SingleActivator(LogicalKeyboardKey.mediaPlayPause): PlayPauseIntent.toggle(),
    // KEYCODE_MEDIA_STOP / 86 / stop
    SingleActivator(LogicalKeyboardKey.mediaStop): PlayPauseIntent.pause(),
    // KEYCODE_MEDIA_NEXT / 87 / skip to next
    SingleActivator(LogicalKeyboardKey.mediaTrackNext): ShowNextIntent(),
    // KEYCODE_MEDIA_PREVIOUS / 88 / skip to previous
    SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): ShowPreviousIntent(),
    // KEYCODE_MEDIA_PLAY / 126 / play
    SingleActivator(LogicalKeyboardKey.mediaPlay): PlayPauseIntent.play(),
    // KEYCODE_MEDIA_PAUSE / 127 / pause
    SingleActivator(LogicalKeyboardKey.mediaPause): PlayPauseIntent.pause(),
    // KEYCODE_BUTTON_L1 / 102 / skip to previous
    SingleActivator(LogicalKeyboardKey.gameButtonLeft1): ShowPreviousIntent(),
    // KEYCODE_BUTTON_R1 / 103 / skip to next
    SingleActivator(LogicalKeyboardKey.gameButtonRight1): ShowNextIntent(),
    // KEYCODE_BUTTON_START / 108 / pause
    SingleActivator(LogicalKeyboardKey.gameButtonStart): PlayPauseIntent.pause(),
    // KEYCODE_BUTTON_SELECT / 109 / play/pause
    SingleActivator(LogicalKeyboardKey.gameButtonSelect): PlayPauseIntent.toggle(),
  };
}
