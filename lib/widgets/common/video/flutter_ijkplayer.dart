// import 'dart:async';
//
// import 'package:aves/model/entry.dart';
// import 'package:aves/utils/change_notifier.dart';
// import 'package:aves/widgets/common/video/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
//
// class IjkPlayerAvesVideoController extends AvesVideoController {
//   IjkMediaController _instance;
//   final List<StreamSubscription> _subscriptions = [];
//   final AChangeNotifier _playFinishNotifier = AChangeNotifier();
//
//   IjkPlayerAvesVideoController() {
//     _instance = IjkMediaController();
//     _subscriptions.add(_instance.playFinishStream.listen((_) => _playFinishNotifier.notifyListeners()));
//   }
//
//   @override
//   void dispose() {
//     _subscriptions
//       ..forEach((sub) => sub.cancel())
//       ..clear();
//     _instance?.dispose();
//   }
//
//   // enable autoplay, even when seeking on uninitialized player, otherwise the texture is not updated
//   // as a workaround, pausing after a brief duration is possible, but fiddly
//   @override
//   Future<void> setDataSource(String uri) => _instance.setDataSource(DataSource.photoManagerUrl(uri), autoPlay: true);
//
//   @override
//   Future<void> refreshVideoInfo() => _instance.refreshVideoInfo();
//
//   @override
//   Future<void> play() => _instance.play();
//
//   @override
//   Future<void> pause() => _instance.pause();
//
//   @override
//   Future<void> seekTo(int targetMillis) => _instance.seekTo(targetMillis / 1000.0);
//
//   @override
//   Future<void> seekToProgress(double progress) => _instance.seekToProgress(progress);
//
//   @override
//   Listenable get playCompletedListenable => _playFinishNotifier;
//
//   @override
//   VideoStatus get status => _instance.ijkStatus.toAves;
//
//   @override
//   Stream<VideoStatus> get statusStream => _instance.ijkStatusStream.map((status) => status.toAves);
//
//   // we check whether video info is ready instead of checking for `noDatasource` status,
//   // as the controller could also be uninitialized with the `pause` status
//   // (e.g. when switching between video entries without playing them the first time)
//   @override
//   bool get isPlayable => _videoInfo.hasData && [VideoStatus.prepared, VideoStatus.playing, VideoStatus.paused, VideoStatus.completed].contains(status);
//
//   @override
//   bool get isVideoReady => _instance.textureId != null;
//
//   @override
//   Stream<bool> get isVideoReadyStream => _instance.textureIdStream.map((id) => id != null);
//
//   // `videoInfo` is never null (even if `toString` prints `null`)
//   // check presence with `hasData` instead
//   VideoInfo get _videoInfo => _instance.videoInfo;
//
//   @override
//   int get duration => _videoInfo.durationMillis;
//
//   @override
//   int get currentPosition => _videoInfo.currentPositionMillis;
//
//   @override
//   Stream<int> get positionStream => _instance.videoInfoStream.map((info) => info.currentPositionMillis);
//
//   @override
//   Widget buildPlayerWidget(BuildContext context, AvesEntry entry) => IjkPlayer(
//         mediaController: _instance,
//         controllerWidgetBuilder: (controller) => SizedBox.shrink(),
//         statusWidgetBuilder: (context, controller, status) => SizedBox.shrink(),
//         textureBuilder: (context, controller, info) {
//           var id = controller.textureId;
//           var child = id != null
//               ? Texture(
//                   textureId: id,
//                 )
//               : Container(
//                   color: Colors.black,
//                 );
//
//           final degree = entry.rotationDegrees ?? 0;
//           if (degree != 0) {
//             child = RotatedBox(
//               quarterTurns: degree ~/ 90,
//               child: child,
//             );
//           }
//
//           return Center(
//             child: AspectRatio(
//               aspectRatio: entry.displayAspectRatio,
//               child: child,
//             ),
//           );
//         },
//         backgroundColor: Colors.transparent,
//       );
// }
//
// extension ExtraVideoInfo on VideoInfo {
//   int get durationMillis => duration == null ? null : (duration * 1000).toInt();
//
//   int get currentPositionMillis => currentPosition == null ? null : (currentPosition * 1000).toInt();
// }
//
// extension ExtraIjkStatus on IjkStatus {
//   VideoStatus get toAves {
//     switch (this) {
//       case IjkStatus.noDatasource:
//         return VideoStatus.idle;
//       case IjkStatus.preparing:
//         return VideoStatus.preparing;
//       case IjkStatus.prepared:
//         return VideoStatus.prepared;
//       case IjkStatus.playing:
//         return VideoStatus.playing;
//       case IjkStatus.pause:
//         return VideoStatus.paused;
//       case IjkStatus.complete:
//         return VideoStatus.completed;
//       case IjkStatus.disposed:
//         return VideoStatus.disposed;
//       case IjkStatus.setDatasourceFail:
//       case IjkStatus.error:
//         return VideoStatus.error;
//     }
//     return VideoStatus.idle;
//   }
// }
