import 'package:aves/model/actions/entry_actions.dart';
import 'package:flutter/widgets.dart';

class ShowPreviousIntent extends Intent {
  const ShowPreviousIntent();
}

class ShowNextIntent extends Intent {
  const ShowNextIntent();
}

class LeaveIntent extends Intent {
  const LeaveIntent();
}

class ShowInfoIntent extends Intent {
  const ShowInfoIntent();
}

class TvShowLessInfoIntent extends Intent {
  const TvShowLessInfoIntent();
}

class TvShowMoreInfoIntent extends Intent {
  const TvShowMoreInfoIntent();
}

class PlayPauseIntent extends Intent {
  final TvPlayPauseType type;

  const PlayPauseIntent.play() : type = TvPlayPauseType.play;

  const PlayPauseIntent.pause() : type = TvPlayPauseType.pause;

  const PlayPauseIntent.toggle() : type = TvPlayPauseType.toggle;
}

enum TvPlayPauseType {
  play,
  pause,
  toggle,
}

class EntryActionIntent extends Intent {
  final EntryAction action;

  const EntryActionIntent({
    required this.action,
  });
}
