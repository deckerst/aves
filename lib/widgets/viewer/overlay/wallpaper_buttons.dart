import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/services/wallpaper_service.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/dialogs/wallpaper_settings_dialog.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/view/conductor.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class WallpaperButtons extends StatelessWidget with FeedbackMixin {
  final AvesEntry entry;
  final Animation<double> scale;

  const WallpaperButtons({
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
              child: ScalingOverlayTextButton(
                scale: scale,
                onPressed: () => _setWallpaper(context),
                child: Text(context.l10n.viewerSetWallpaperButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setWallpaper(BuildContext context) async {
    final l10n = context.l10n;
    final value = await showDialog<(WallpaperTarget, bool)>(
      context: context,
      builder: (context) => const WallpaperSettingsDialog(),
      routeSettings: const RouteSettings(name: WallpaperSettingsDialog.routeName),
    );
    if (value == null) return;

    final reportController = StreamController.broadcast();
    unawaited(showOpReport(
      context: context,
      opStream: reportController.stream,
    ));

    var region = _getVisibleRegion(context);
    if (region == null) return;

    final (target, useScrollEffect) = value;
    if (useScrollEffect) {
      final deltaX = min(region.left, entry.displaySize.width - region.right);
      region = Rect.fromLTRB(region.left - deltaX, region.top, region.right + deltaX, region.bottom);
    }

    final bytes = await _getBytes(context, region);

    final success = bytes != null && await WallpaperService.set(bytes, target);
    unawaited(reportController.close());

    if (success) {
      await SystemNavigator.pop();
    } else {
      showFeedback(context, l10n.genericFailureFeedback);
    }
  }

  Rect? _getVisibleRegion(BuildContext context) {
    final viewState = context.read<ViewStateConductor>().getOrCreateController(entry).viewState;
    final viewportSize = viewState.viewportSize;
    final contentSize = viewState.contentSize;
    final scale = viewState.scale;
    if (viewportSize == null || contentSize == null || contentSize.isEmpty || scale == null) return null;

    final center = (contentSize / 2 - viewState.position / scale) as Size;
    final regionSize = viewportSize / scale;
    final regionTopLeft = (center - regionSize / 2) as Offset;
    return regionTopLeft & regionSize;
  }

  Future<Uint8List?> _getBytes(BuildContext context, Rect displayRegion) async {
    final viewState = context.read<ViewStateConductor>().getOrCreateController(entry).viewState;
    final scale = viewState.scale;

    final displaySize = entry.displaySize;
    if (displaySize.isEmpty || scale == null) return null;

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
        if (bytes != null) {
          needOrientation = rotationDegrees != 0 || isFlipped;
          needCrop = true;
          provider = MemoryImage(bytes);
        }
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
            case 180:
              canvas.translate(0, imageDisplaySize.height);
              canvas.rotate(degToRadian(180));
            case 270:
              canvas.rotate(degToRadian(90));
          }
        } else {
          switch (rotationDegrees) {
            case 90:
              canvas.translate(imageDisplaySize.width, 0);
              cropDx = -displayRegion.top.toDouble();
              cropDy = displayRegion.left.toDouble();
            case 180:
              canvas.translate(imageDisplaySize.width, imageDisplaySize.height);
            case 270:
              canvas.translate(0, imageDisplaySize.height);
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
