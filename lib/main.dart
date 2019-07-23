import 'package:aves/common/fake_app_bar.dart';
import 'package:aves/model/image_fetcher.dart';
import 'package:aves/thumbnail_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aves',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.amberAccent,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Map>> _entryListLoader;

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    _entryListLoader = ImageFetcher.getImageEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // fake app bar so that content is safe from status bar, even though we use a SliverAppBar
      appBar: FakeAppBar(),
      body: Container(
        child: FutureBuilder(
          future: _entryListLoader,
          builder: (futureContext, AsyncSnapshot<List<Map>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
              return ThumbnailCollection(entries: snapshot.data);
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
