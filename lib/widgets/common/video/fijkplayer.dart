// import 'dart:async';
//
// import 'package:aves/model/entry.dart';
// import 'package:aves/utils/change_notifier.dart';
// import 'package:aves/widgets/common/video/video.dart';
// import 'package:fijkplayer/fijkplayer.dart';
// import 'package:flutter/material.dart';
//
// class FijkPlayerAvesVideoController extends AvesVideoController {
//   FijkPlayer _instance;
//   final List<StreamSubscription> _subscriptions = [];
//   final StreamController<FijkValue> _valueStreamController = StreamController.broadcast();
//   final AChangeNotifier _playFinishNotifier = AChangeNotifier();
//
//   Stream<FijkValue> get _valueStream => _valueStreamController.stream;
//
//   FijkPlayerAvesVideoController() {
//     _instance = FijkPlayer();
//     _instance.addListener(_onValueChanged);
//     _subscriptions.add(_valueStream.where((value) => value.completed).listen((_) => _playFinishNotifier.notifyListeners()));
//   }
//
//   @override
//   void dispose() {
//     _instance.removeListener(_onValueChanged);
//     _valueStreamController.close();
//     _subscriptions
//       ..forEach((sub) => sub.cancel())
//       ..clear();
//     _instance.release();
//   }
//
//   void _onValueChanged() => _valueStreamController.add(_instance.value);
//
//   // enable autoplay, even when seeking on uninitialized player, otherwise the texture is not updated
//   // as a workaround, pausing after a brief duration is possible, but fiddly
//   @override
//   Future<void> setDataSource(String uri) => _instance.setDataSource(uri, autoPlay: true);
//
//   @override
//   Future<void> refreshVideoInfo() => null;
//
//   @override
//   Future<void> play() => _instance.start();
//
//   @override
//   Future<void> pause() => _instance.pause();
//
//   @override
//   Future<void> seekTo(int targetMillis) => _instance.seekTo(targetMillis);
//
//   @override
//   Future<void> seekToProgress(double progress) => _instance.seekTo((duration * progress).toInt());
//
//   @override
//   Listenable get playCompletedListenable => _playFinishNotifier;
//
//   @override
//   VideoStatus get status => _instance.state.toAves;
//
//   @override
//   Stream<VideoStatus> get statusStream => _valueStream.map((value) => value.state.toAves);
//
//   @override
//   bool get isVideoReady => _instance.value.videoRenderStart;
//
//   @override
//   Stream<bool> get isVideoReadyStream => _valueStream.map((value) => value.videoRenderStart);
//
//   // we check whether video info is ready instead of checking for `noDatasource` status,
//   // as the controller could also be uninitialized with the `pause` status
//   // (e.g. when switching between video entries without playing them the first time)
//   @override
//   bool get isPlayable => _instance.isPlayable();
//
//   @override
//   int get duration => _instance.value.duration.inMilliseconds;
//
//   @override
//   int get currentPosition => _instance.currentPos.inMilliseconds;
//
//   @override
//   Stream<int> get positionStream => _instance.onCurrentPosUpdate.map((pos) => pos.inMilliseconds);
//
//   @override
//   Widget buildPlayerWidget(AvesEntry entry) => FijkView(
//         player: _instance,
//         panelBuilder: (player, data, context, viewSize, texturePos) => SizedBox(),
//         color: Colors.transparent,
//       );
// }
//
// extension ExtraIjkStatus on FijkState {
//   VideoStatus get toAves {
//     switch (this) {
//       case FijkState.idle:
//         return VideoStatus.idle;
//       case FijkState.initialized:
//         return VideoStatus.initialized;
//       case FijkState.asyncPreparing:
//         return VideoStatus.preparing;
//       case FijkState.prepared:
//         return VideoStatus.prepared;
//       case FijkState.started:
//         return VideoStatus.playing;
//       case FijkState.paused:
//         return VideoStatus.paused;
//       case FijkState.completed:
//         return VideoStatus.completed;
//       case FijkState.stopped:
//         return VideoStatus.stopped;
//       case FijkState.end:
//         return VideoStatus.disposed;
//       case FijkState.error:
//         return VideoStatus.error;
//     }
//     return VideoStatus.idle;
//   }
// }
