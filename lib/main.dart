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
  List<Map> imageEntryList;

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    getImageEntries();
  }

  getImageEntries() async {
    imageEntryList = await ImageFetcher.getImageEntries();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MediaQuery.of(context).viewInsets.bottom=${MediaQuery.of(context).viewInsets.bottom}');

    return MediaQuery.removeViewInsets(
      context: context,
      // remove bottom view insets to paint underneath the translucent navigation bar
      removeBottom: true,
      child: Scaffold(
        // fake app bar so that content is safe from status bar, even though we use a SliverAppBar
        appBar: FakeAppBar(),
        body: imageEntryList == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ThumbnailCollection(imageEntryList),
      ),
    );
  }
}
