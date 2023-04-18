import 'dart:io';

import 'package:flutter/services.dart';

class AvesScreenState {
  final EventChannel _eventChannel = const EventChannel('deckers.thibault/aves_screen_state/events');
  Stream<ScreenStateEvent>? _screenStateStream;

  Stream<ScreenStateEvent>? get screenStateStream {
    if (Platform.isAndroid) {
      _screenStateStream ??= _eventChannel.receiveBroadcastStream().map((event) => _parse(event as String));
      return _screenStateStream;
    }
    throw ScreenStateException('Screen State API is only available on Android.');
  }

  ScreenStateEvent _parse(String event) {
    switch (event) {
      case 'android.intent.action.SCREEN_OFF':
        return ScreenStateEvent.off;
      case 'android.intent.action.SCREEN_ON':
        return ScreenStateEvent.on;
      case 'android.intent.action.USER_PRESENT':
        return ScreenStateEvent.unlocked;
      default:
        throw ArgumentError('$event was not recognized.');
    }
  }
}

enum ScreenStateEvent { unlocked, on, off }

class ScreenStateException implements Exception {
  final String _cause;

  ScreenStateException(this._cause);

  @override
  String toString() => _cause;
}
