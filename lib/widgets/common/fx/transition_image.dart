import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// adapted from Flutter `RawImage`, `paintImage()` from `DecorationImagePainter`, etc.
// to transition between 2 different fits during hero animation:
// - BoxFit.cover at t=0
// - BoxFit.contain at t=1

class TransitionImage extends StatefulWidget {
  final ImageProvider image;
  final double? width, height;
  final ValueListenable<double> animation;
  final bool gaplessPlayback = false;
  final Color? background;

  const TransitionImage({
    Key? key,
    required this.image,
    required this.animation,
    this.width,
    this.height,
    this.background,
  }) : super(key: key);

  @override
  _TransitionImageState createState() => _TransitionImageState();
}

class _TransitionImageState extends State<TransitionImage> {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  bool _isListeningToStream = false;
  int? _frameNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _stopListeningToStream();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _resolveImage();

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream();
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TransitionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isListeningToStream) {
      _imageStream!.removeListener(_getListener());
      _imageStream!.addListener(_getListener());
    }
    if (widget.image != oldWidget.image) _resolveImage();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    final provider = widget.image;
    final newStream = provider.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null ? Size(widget.width!, widget.height!) : null,
    ));
    _updateSourceStream(newStream);
  }

  ImageStreamListener _getListener() {
    return ImageStreamListener(
      _handleImageFrame,
      onChunk: null,
    );
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
      _frameNumber = _frameNumber == null ? 0 : _frameNumber! + 1;
    });
  }

  // Updates _imageStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) return;

    if (_isListeningToStream) _imageStream!.removeListener(_getListener());

    if (!widget.gaplessPlayback) {
      setState(() {
        _imageInfo = null;
      });
    }

    setState(() {
      _frameNumber = null;
    });

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream!.addListener(_getListener());
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream!.addListener(_getListener());
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) return;
    _imageStream!.removeListener(_getListener());
    _isListeningToStream = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.animation,
      builder: (context, t, child) => CustomPaint(
        painter: _TransitionImagePainter(
          image: _imageInfo?.image,
          scale: _imageInfo?.scale ?? 1.0,
          t: t,
          background: widget.background,
        ),
      ),
    );
  }
}

class _TransitionImagePainter extends CustomPainter {
  final ui.Image? image;
  final double scale;
  final double t;
  final Color? background;

  const _TransitionImagePainter({
    required this.image,
    required this.scale,
    required this.t,
    this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.low;
    const alignment = Alignment.center;

    final rect = ui.Rect.fromLTWH(0, 0, size.width, size.height);
    final inputSize = Size(image!.width.toDouble(), image!.height.toDouble());
    final outputSize = rect.size;

    final coverSizes = applyBoxFit(BoxFit.cover, inputSize / scale, size);
    final containSizes = applyBoxFit(BoxFit.contain, inputSize / scale, size);
    final sourceSize = Size.lerp(coverSizes.source, containSizes.source, t)! * scale;
    final destinationSize = Size.lerp(coverSizes.destination, containSizes.destination, t)!;

    final halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
    final halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;
    final dx = halfWidthDelta + alignment.x * halfWidthDelta;
    final dy = halfHeightDelta + alignment.y * halfHeightDelta;
    final destinationPosition = rect.topLeft.translate(dx, dy);
    final destinationRect = destinationPosition & destinationSize;
    final sourceRect = alignment.inscribe(
      sourceSize,
      Offset.zero & inputSize,
    );
    if (background != null) {
      // deflate to avoid background artifact around opaque image
      canvas.drawRect(destinationRect.deflate(1), Paint()..color = background!);
    }
    canvas.drawImageRect(image!, sourceRect, destinationRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
