import 'dart:io';
import 'dart:math';

import 'package:aves/image_fullscreen_overlay.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageFullscreenPage extends StatefulWidget {
  final List<Map> entries;
  final String initialUri;

  ImageFullscreenPage({this.entries, this.initialUri});

  @override
  ImageFullscreenPageState createState() => ImageFullscreenPageState();
}

class ImageFullscreenPageState extends State<ImageFullscreenPage> {
  int _currentPage;
  PageController _pageController;

  List<Map> get entries => widget.entries;

  @override
  void initState() {
    super.initState();
    var index = entries.indexWhere((entry) => entry['uri'] == widget.initialUri);
    _currentPage = max(0, index);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PhotoViewGallery.builder(
            itemCount: entries.length,
            builder: (context, index) {
              var entry = entries[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(entry['path'])),
                heroTag: entry['uri'],
                minScale: PhotoViewComputedScale.contained,
                initialScale: PhotoViewComputedScale.contained,
              );
            },
            loadingChild: Center(
              child: CircularProgressIndicator(),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              debugPrint('onPageChanged: index=$index');
              setState(() => _currentPage = index);
            },
            transitionOnUserGestures: true,
            scrollPhysics: BouncingScrollPhysics(),
          ),
          if (_currentPage != null)
            FullscreenOverlay(
              entries: entries,
              index: _currentPage,
            ),
        ],
      ),
      resizeToAvoidBottomInset: false,
//        Hero(
//          tag: uri,
//          child: Stack(
//            children: [
//              Center(
//                child: widget.thumbnail == null
//                    ? CircularProgressIndicator()
//                    : Image.memory(
//                        widget.thumbnail,
//                        width: requestWidth,
//                        height: requestHeight,
//                        fit: BoxFit.contain,
//                      ),
//              ),
//              Center(
//                child: FadeInImage(
//                  placeholder: MemoryImage(kTransparentImage),
//                  image: FileImage(File(path)),
//                  fadeOutDuration: Duration(milliseconds: 1),
//                  fadeInDuration: Duration(milliseconds: 200),
//                  width: requestWidth,
//                  height: requestHeight,
//                  fit: BoxFit.contain,
//                ),
//              ),
//            ],
//          ),
//        ),
    );
  }
}
