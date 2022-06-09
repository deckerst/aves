import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/wallpaper_target.dart';
import 'package:aves/services/wallpaper_service.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/viewer_button_row.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class WallpaperButton extends StatelessWidget with FeedbackMixin {
  final AvesEntry entry;
  final Animation<double> scale;

  const WallpaperButton({
    super.key,
    required this.entry,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const padding = ViewerButtonRowContent.padding;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: padding / 2, right: padding / 2, bottom: padding),
        child: Row(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding / 2),
              child: OverlayTextButton(
                scale: scale,
                buttonLabel: context.l10n.viewerSetWallpaperButtonLabel,
                onPressed: () => _setWallpaper(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setWallpaper(BuildContext context) async {
    final l10n = context.l10n;
    var target = WallpaperTarget.home;
    if (device.canSetLockScreenWallpaper) {
      final value = await showDialog<WallpaperTarget>(
        context: context,
        builder: (context) => AvesSelectionDialog<WallpaperTarget>(
          initialValue: WallpaperTarget.home,
          options: Map.fromEntries(WallpaperTarget.values.map((v) => MapEntry(v, v.getName(context)))),
          confirmationButtonLabel: l10n.continueButtonLabel,
        ),
      );
      if (value == null) return;
      target = value;
    }

    final reportController = StreamController.broadcast();
    unawaited(showOpReport(
      context: context,
      opStream: reportController.stream,
    ));

    final viewState = context.read<ViewStateConductor>().getOrCreateController(entry).value;
    final viewportSize = viewState.viewportSize;
    final contentSize = viewState.contentSize;
    final scale = viewState.scale;
    if (viewportSize == null || contentSize == null || contentSize.isEmpty || scale == null) return;

    final center = (contentSize / 2 - viewState.position / scale) as Size;
    final regionSize = viewportSize / scale;
    final regionTopLeft = (center - regionSize / 2) as Offset;
    final region = Rect.fromLTWH(regionTopLeft.dx, regionTopLeft.dy, regionSize.width, regionSize.height);
    final bytes = await _getBytes(context, scale, region);

    final success = bytes != null && await WallpaperService.set(bytes, target);
    unawaited(reportController.close());

    if (success) {
      await SystemNavigator.pop();
    } else {
      showFeedback(context, l10n.genericFailureFeedback);
    }
  }

  Future<Uint8List?> _getBytes(BuildContext context, double scale, Rect displayRegion) async {
    final displaySize = entry.displaySize;
    if (displaySize.isEmpty) return null;

    var storageRegion = Rectangle(
      displayRegion.left,
      displayRegion.top,
      displayRegion.width,
      displayRegion.height,
    );

    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;
    var needCrop = false, needOrientation = false;

    ImageProvider? provider;
    if (entry.isSvg) {
      provider = entry.getRegion(
        scale: scale,
        region: storageRegion,
      );
    } else if (entry.isVideo) {
      final videoController = context.read<VideoConductor>().getController(entry);
      if (videoController != null) {
        final bytes = await videoController.captureFrame();
        needOrientation = rotationDegrees != 0 || isFlipped;
        needCrop = true;
        provider = MemoryImage(bytes);
      }
    } else if (entry.canDecode) {
      if (entry.useTiles) {
        // provider image is already cropped, but not rotated
        needOrientation = rotationDegrees != 0 || isFlipped;
        if (needOrientation) {
          final transform = Matrix4.identity()
            ..translate(entry.width / 2.0, entry.height / 2.0)
            ..scale(isFlipped ? -1.0 : 1.0, 1.0, 1.0)
            ..rotateZ(-degToRadian(rotationDegrees.toDouble()))
            ..translate(-displaySize.width / 2.0, -displaySize.height / 2.0);

          // apply EXIF orientation
          final regionRectDouble = Rect.fromLTWH(displayRegion.left.toDouble(), displayRegion.top.toDouble(), displayRegion.width.toDouble(), displayRegion.height.toDouble());
          final tl = MatrixUtils.transformPoint(transform, regionRectDouble.topLeft);
          final br = MatrixUtils.transformPoint(transform, regionRectDouble.bottomRight);
          storageRegion = Rectangle<double>.fromPoints(
            Point<double>(tl.dx, tl.dy),
            Point<double>(br.dx, br.dy),
          );
        }

        final sampleSize = ExtraAvesEntryImages.sampleSizeForScale(scale);
        provider = entry.getRegion(sampleSize: sampleSize, region: storageRegion);
        displayRegion = Rect.fromLTWH(
          displayRegion.left / sampleSize,
          displayRegion.top / sampleSize,
          displayRegion.width / sampleSize,
          displayRegion.height / sampleSize,
        );
      } else {
        // provider image is already rotated, but not cropped
        needCrop = true;
        provider = entry.uriImage;
      }
    }
    if (provider == null) return null;

    final imageInfoCompleter = Completer<ImageInfo?>();
    final imageStream = provider.resolve(ImageConfiguration.empty);
    final imageStreamListener = ImageStreamListener((image, synchronousCall) async {
      imageInfoCompleter.complete(image);
    }, onError: imageInfoCompleter.completeError);
    imageStream.addListener(imageStreamListener);
    ImageInfo? regionImageInfo;
    try {
      regionImageInfo = await imageInfoCompleter.future;
    } catch (error) {
      debugPrint('failed to get image for region=$displayRegion with error=$error');
    }
    imageStream.removeListener(imageStreamListener);
    var image = regionImageInfo?.image;
    if (image == null) return null;

    if (needCrop || needOrientation) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final w = image.width.toDouble();
      final h = image.height.toDouble();
      final imageDisplaySize = entry.isRotated ? Size(h, w) : Size(w, h);
      var cropDx = -displayRegion.left.toDouble();
      var cropDy = -displayRegion.top.toDouble();

      if (needOrientation) {
        // apply EXIF orientation
        if (isFlipped) {
          canvas.scale(-1, 1);
          switch (rotationDegrees) {
            case 90:
              canvas.translate(-imageDisplaySize.width, imageDisplaySize.height);
              canvas.rotate(degToRadian(270));
              break;
            case 180:
              canvas.translate(0, imageDisplaySize.height);
              canvas.rotate(degToRadian(180));
              break;
            case 270:
              canvas.rotate(degToRadian(90));
              break;
          }
        } else {
          switch (rotationDegrees) {
            case 90:
              canvas.translate(imageDisplaySize.width, 0);
              cropDx = -displayRegion.top.toDouble();
              cropDy = displayRegion.left.toDouble();
              break;
            case 180:
              canvas.translate(imageDisplaySize.width, imageDisplaySize.height);
              break;
            case 270:
              canvas.translate(0, imageDisplaySize.height);
              break;
          }
          if (rotationDegrees != 0) {
            canvas.rotate(degToRadian(rotationDegrees.toDouble()));
          }
        }
      }

      if (needCrop) {
        canvas.translate(cropDx, cropDy);
      }
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final renderSize = Size(
        displayRegion.width.toDouble(),
        displayRegion.height.toDouble(),
      );
      image = await picture.toImage(renderSize.width.round(), renderSize.height.round());
    }

    // bytes should be compressed to be decodable on the platform side
    return await image.toByteData(format: ui.ImageByteFormat.png).then((v) => v?.buffer.asUint8List());
  }
}
