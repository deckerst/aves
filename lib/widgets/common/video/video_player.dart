// import 'dart:async';
//
// import 'package:aves/model/entry.dart';
// import 'package:aves/utils/change_notifier.dart';
// import 'package:aves/widgets/common/video/controller.dart';
// import 'package:flutter/src/foundation/change_notifier.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerAvesVideoController extends AvesVideoController {
//   VideoPlayerController _instance;
//   final List<StreamSubscription> _subscriptions = [];
//   final StreamController<VideoPlayerValue> _valueStreamController = StreamController.broadcast();
//   final AChangeNotifier _playFinishNotifier = AChangeNotifier();
//
//   Stream<VideoPlayerValue> get _valueStream => _valueStreamController.stream;
//
//   VideoPlayerAvesVideoController();
//
//   @override
//   Future<void> setDataSource(String uri) async {
//     _instance = VideoPlayerController.network(uri);
//     _instance.addListener(_onValueChanged);
//     _subscriptions.add(_valueStream.where((value) => value.position > value.duration).listen((_) => _playFinishNotifier.notifyListeners()));
//
//     await _instance.initialize();
//     await play();
//   }
//
//   @override
//   void dispose() {
//     _instance?.removeListener(_onValueChanged);
//     _valueStreamController.close();
//     _subscriptions
//       ..forEach((sub) => sub.cancel())
//       ..clear();
//     _instance?.dispose();
//   }
//
//   void _onValueChanged() => _valueStreamController.add(_instance.value);
//
//   @override
//   Future<void> refreshVideoInfo() => null;
//
//   @override
//   Future<void> play() => _instance.play();
//
//   @override
//   Future<void> pause() => _instance?.pause();
//
//   @override
//   Future<void> seekTo(int targetMillis) => _instance.seekTo(Duration(milliseconds: targetMillis));
//
//   @override
//   Future<void> seekToProgress(double progress) => _instance.seekTo(Duration(milliseconds: (duration * progress).toInt()));
//
//   @override
//   Listenable get playCompletedListenable => _playFinishNotifier;
//
//   @override
//   VideoStatus get status => _instance?.value?.toAves ?? VideoStatus.idle;
//
//   @override
//   Stream<VideoStatus> get statusStream => _valueStream.map((value) => value.toAves);
//
//   @override
//   bool get isVideoReady => _instance != null && _instance.value.isInitialized && !_instance.value.hasError;
//
//   @override
//   Stream<bool> get isVideoReadyStream => _valueStream.map((value) => value.isInitialized && !value.hasError);
//
//   @override
//   bool get isPlayable => _instance != null && _instance.value.isInitialized && !_instance.value.hasError;
//
//   @override
//   int get duration => _instance?.value?.duration?.inMilliseconds;
//
//   @override
//   int get currentPosition => _instance?.value?.position?.inMilliseconds;
//
//   @override
//   Stream<int> get positionStream => _valueStream.map((value) => value.position.inMilliseconds);
//
//   @override
//   Widget buildPlayerWidget(BuildContext context, AvesEntry entry) => VideoPlayer(_instance);
// }
//
// extension ExtraVideoPlayerValue on VideoPlayerValue {
//   VideoStatus get toAves {
//     if (hasError) return VideoStatus.error;
//     if (!isInitialized) return VideoStatus.idle;
//     if (isPlaying) return VideoStatus.playing;
//     return VideoStatus.paused;
//   }
// }
