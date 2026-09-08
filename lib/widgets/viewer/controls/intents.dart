import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

class ShowPreviousIntent extends Intent {
  const new();
}

class ShowNextIntent extends Intent {
  const new();
}

class LeaveIntent extends Intent {
  const new();
}

class ShowInfoIntent extends Intent {
  const new();
}

class TvShowLessInfoIntent extends Intent {
  const new();
}

class TvShowMoreInfoIntent extends Intent {
  const new();
}

class PlayPauseIntent extends Intent {
  final TvPlayPauseType type;

  const new play() : type = TvPlayPauseType.play;

  const new pause() : type = TvPlayPauseType.pause;

  const new toggle() : type = TvPlayPauseType.toggle;
}

enum TvPlayPauseType {
  play,
  pause,
  toggle,
}

class EntryActionIntent extends Intent {
  final EntryAction action;

  const new({
    required this.action,
  });
}
