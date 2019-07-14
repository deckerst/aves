import 'dart:typed_data';

import 'package:aves/settings.dart';
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

  static Future<List> getImageEntries() async {
    try {
      final result = await platform.invokeMethod('getImageEntries');
      return result as List;
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
    }
    return [];
  }

  static Future<Uint8List> getImageBytes(Map entry, int width, int height) async {
    try {
      final result = await platform.invokeMethod('getImageBytes', <String, dynamic>{
        'entry': entry,
        'width': width,
        'height': height,
      });
      return result as Uint8List;
    } on PlatformException catch (e) {
      debugPrint('failed with exception=${e.message}');
    }
    return Uint8List(0);
  }

  static cancelGetImageBytes(String uri) async {
    try {
      await platform.invokeMethod('cancelGetImageBytes', <String, dynamic>{
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
    imageLoader = ImageFetcher.getImageEntries();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      settings.devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      debugPrint('$runtimeType devicePixelRatio=${settings.devicePixelRatio}');
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
                        return Thumbnail(
                          entry: imageEntryList[index] as Map,
                          extent: extent,
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
