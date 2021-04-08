// import 'dart:async';
// import 'dart:io';
//
// import 'package:aves/model/entry.dart';
// import 'package:aves/utils/change_notifier.dart';
// import 'package:aves/widgets/common/video/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/change_notifier.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:provider/provider.dart';
//
// class VlcAvesVideoController extends AvesVideoController {
//   VlcPlayerController _instance;
//   final List<StreamSubscription> _subscriptions = [];
//   final StreamController<VlcPlayerValue> _valueStreamController = StreamController.broadcast();
//   final AChangeNotifier _playFinishNotifier = AChangeNotifier();
//
//   Stream<VlcPlayerValue> get _valueStream => _valueStreamController.stream;
//
//   VlcAvesVideoController();
//
//   @override
//   Future<void> setDataSource(String uri) async {
//     _instance = VlcPlayerController.file(
//       File(uri),
//     );
//     _instance.addListener(_onValueChanged);
//     _subscriptions.add(_valueStream.where((value) => value.isEnded).listen((_) => _playFinishNotifier.notifyListeners()));
//
//     // update value stream to:
//     // 1) trigger playability check
//     // 2) show the `VlcPlayer` widget
//     // 3) initialize its `PlatformView`
//     // 4) complete `VlcPlayerController` initialization
//     _valueStreamController.add(_instance.value);
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
//   bool get isPlayable => _instance != null;
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
//   Widget buildPlayerWidget(BuildContext context, AvesEntry entry) {
//     // do not use `Magnifier` with `applyScale` enabled when using this widget,
//     // as the original video size will be used to create the `PlatformView`
//     // and a virtual display larger than the device screen may crash the app
//     final mqWidth = context.select<MediaQueryData, double>((mq) => mq.size.width);
//     final displaySize = entry.displaySize;
//     final ratio = mqWidth / displaySize.width;
//     return SizedBox.fromSize(
//       size: displaySize * ratio,
//       child: VlcPlayer(
//         controller: _instance,
//         aspectRatio: entry.displayAspectRatio,
//       ),
//     );
//   }
// }
//
// extension ExtraVlcPlayerValue on VlcPlayerValue {
//   VideoStatus get toAves {
//     if (hasError) return VideoStatus.error;
//     if (!isInitialized) return VideoStatus.idle;
//     if (isEnded) return VideoStatus.completed;
//     if (isPlaying) return VideoStatus.playing;
//     return VideoStatus.paused;
//   }
// }
