import 'dart:io';
import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
              entry: entries[_currentPage],
              index: _currentPage,
              total: entries.length,
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

class FullscreenOverlay extends StatelessWidget {
  final Map entry;
  final int index, total;

  FullscreenOverlay({this.entry, this.index, this.total});

  @override
  Widget build(BuildContext context) {
    var viewInsets = MediaQuery.of(context).viewInsets;
    var date = ImageEntry.getBestDate(entry);
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.all(8.0).add(EdgeInsets.only(bottom: viewInsets.bottom)),
        color: Colors.black45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1} / $total - ${entry['title']}'),
            Row(
              children: [
                Expanded(child: Text('${DateFormat.yMMMd().format(date)} – ${DateFormat.Hm().format(date)}')),
                Expanded(child: Text('${entry['width']} × ${entry['height']}')),
              ],
            ),
            FutureBuilder(
              future: ImageFetcher.getOverlayMetadata(entry['path']),
              builder: (futureContext, AsyncSnapshot<Map> snapshot) {
                if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
                  return Text('');
                }
                var metadata = snapshot.data;
                if (metadata.isEmpty) {
                  return Text('');
                }
                return Row(
                  children: [
                    Expanded(child: Text(metadata['aperture'])),
                    Expanded(child: Text(metadata['exposureTime'])),
                    Expanded(child: Text(metadata['focalLength'])),
                    Expanded(child: Text(metadata['iso'])),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
