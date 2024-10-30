import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// adapted from Flutter `_ImageState` in `/widgets/image.dart`
// and `DecorationImagePainter` in `/painting/decoration_image.dart`
// to transition between 2 different fits during hero animation:
// - BoxFit.cover at t=0
// - BoxFit.contain at t=1

class TransitionImage extends StatefulWidget {
  final ImageProvider image;
  final ValueListenable<double> animation;
  final BoxFit thumbnailFit, viewerFit;
  final Color? background;

  const TransitionImage({
    super.key,
    required this.image,
    required this.animation,
    required this.thumbnailFit,
    required this.viewerFit,
    this.background,
  });

  @override
  State<TransitionImage> createState() => _TransitionImageState();
}

class _TransitionImageState extends State<TransitionImage> with WidgetsBindingObserver {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  bool _isListeningToStream = false;
  bool _wasSynchronouslyLoaded = false;
  late DisposableBuildContext<State<TransitionImage>> _scrollAwareContext;
  ImageStreamCompleterHandle? _completerHandle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollAwareContext = DisposableBuildContext<State<TransitionImage>>(this);
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    WidgetsBinding.instance.removeObserver(this);
    _stopListeningToStream();
    _completerHandle?.dispose();
    _scrollAwareContext.dispose();
    _replaceImage(info: null);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _resolveImage();

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream(keepStreamAlive: true);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TransitionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _resolveImage();
    }
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    final ScrollAwareImageProvider provider = ScrollAwareImageProvider<Object>(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );
    final ImageStream newStream = provider.resolve(createLocalImageConfiguration(context));
    _updateSourceStream(newStream);
  }

  ImageStreamListener? _imageStreamListener;

  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _imageStreamListener = ImageStreamListener(_handleImageFrame);
    }
    return _imageStreamListener!;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _replaceImage(info: imageInfo);
      _wasSynchronouslyLoaded = _wasSynchronouslyLoaded | synchronousCall;
    });
  }

  void _replaceImage({required ImageInfo? info}) {
    final ImageInfo? oldImageInfo = _imageInfo;
    SchedulerBinding.instance.addPostFrameCallback((_) => oldImageInfo?.dispose());
    _imageInfo = info;
  }

  // Updates _imageStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) {
      return;
    }

    if (_isListeningToStream) {
      _imageStream!.removeListener(_getListener());
    }

    setState(() {
      _replaceImage(info: null);
      _wasSynchronouslyLoaded = false;
    });

    _imageStream = newStream;
    if (_isListeningToStream) {
      _imageStream!.addListener(_getListener());
    }
  }

  void _listenToStream() {
    if (_isListeningToStream) {
      return;
    }

    _imageStream!.addListener(_getListener());
    _completerHandle?.dispose();
    _completerHandle = null;

    _isListeningToStream = true;
  }

  /// Stops listening to the image stream, if this state object has attached a
  /// listener.
  ///
  /// If the listener from this state is the last listener on the stream, the
  /// stream will be disposed. To keep the stream alive, set `keepStreamAlive`
  /// to true, which create [ImageStreamCompleterHandle] to keep the completer
  /// alive and is compatible with the [TickerMode] being off.
  void _stopListeningToStream({bool keepStreamAlive = false}) {
    if (!_isListeningToStream) {
      return;
    }

    if (keepStreamAlive && _completerHandle == null && _imageStream?.completer != null) {
      _completerHandle = _imageStream!.completer!.keepAlive();
    }

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
          thumbnailFit: widget.thumbnailFit,
          viewerFit: widget.viewerFit,
          background: widget.background,
        ),
      ),
    );
  }
}

class _TransitionImagePainter extends CustomPainter {
  final ui.Image? image;
  final double scale, t;
  final Color? background;
  final BoxFit thumbnailFit, viewerFit;

  static final _paint = Paint()
    ..isAntiAlias = false
    ..filterQuality = FilterQuality.low;
  static const _alignment = Alignment.center;

  const _TransitionImagePainter({
    required this.image,
    required this.scale,
    required this.t,
    required this.thumbnailFit,
    required this.viewerFit,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _image = image;
    if (_image == null) return;

    if (size.isEmpty) {
      return;
    }

    final outputSize = size;
    final inputSize = Size(_image.width.toDouble(), _image.height.toDouble());

    final thumbnailSizes = applyBoxFit(thumbnailFit, inputSize / scale, size);
    final viewerSizes = applyBoxFit(viewerFit, inputSize / scale, size);
    final sourceSize = Size.lerp(thumbnailSizes.source, viewerSizes.source, t)! * scale;
    final destinationSize = Size.lerp(thumbnailSizes.destination, viewerSizes.destination, t)!;

    final halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
    final halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;
    final dx = halfWidthDelta + _alignment.x * halfWidthDelta;
    final dy = halfHeightDelta + _alignment.y * halfHeightDelta;
    final destinationPosition = Offset(dx, dy);

    final destinationRect = destinationPosition & destinationSize;
    final sourceRect = _alignment.inscribe(
      sourceSize,
      Offset.zero & inputSize,
    );
    if (background != null) {
      // deflate to avoid background artifact around opaque image
      canvas.drawRect(destinationRect.deflate(1), Paint()..color = background!);
    }
    canvas.drawImageRect(_image, sourceRect, destinationRect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
