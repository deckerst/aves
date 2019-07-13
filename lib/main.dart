import 'dart:typed_data';
import 'package:aves/image_fullscreen_page.dart';
import 'package:aves/thumbnail.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ImageFetcher {
  static const platform = const MethodChannel('deckers.thibault.aves/mediastore');

  static double devicePixelRatio;

  static Future<List> getImages() async {
    try {
      final result = await platform.invokeMethod('getImages');
      return result as List;
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
    }
    return [];
  }

  static Future<Uint8List> getThumbnail(Map entry, double width, double height) async {
    try {
      final result = await platform.invokeMethod('getThumbnail', <String, dynamic>{
        'entry': entry,
        'width': (width * devicePixelRatio).round(),
        'height': (height * devicePixelRatio).round(),
      });
      return result as Uint8List;
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
    }
    return Uint8List(0);
  }

  static cancelGetThumbnail(String uri) async {
    try {
      await platform.invokeMethod('cancelGetThumbnail', <String, dynamic>{
        'uri': uri,
      });
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List> imageLoader;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    imageLoader = ImageFetcher.getImages();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ImageFetcher.devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      debugPrint('$runtimeType devicePixelRatio=${ImageFetcher.devicePixelRatio}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var columnCount = 4;
    var extent = MediaQuery.of(context).size.width / columnCount;
    debugPrint('MediaQuery.of(context).size=${MediaQuery.of(context).size} extent=$extent');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: imageLoader,
          builder: (futureContext, AsyncSnapshot<List> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('None');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Text('Awaiting result...');
              case ConnectionState.done:
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                var imageEntryList = snapshot.data;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  child: DraggableScrollbar.arrows(
                    labelTextBuilder: (double offset) => Text(
                          "${offset ~/ 1}",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                    controller: scrollController,
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: extent,
                      ),
                      itemBuilder: (gridContext, index) {
                        var imageEntryMap = imageEntryList[index] as Map;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ImageFullscreenPage(entry: imageEntryMap)),
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade700,
                                width: 0.5,
                              ),
                            ),
                            child: Thumbnail(
                              entry: imageEntryMap,
                              extent: extent,
                            ),
                          ),
                        );
                      },
                      itemCount: imageEntryList.length,
                    ),
                  ),
                );
            }
            return null;
          }),
    );
  }
}
